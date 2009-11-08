require 'ffi'

module GLib
  private
  module Lib
    extend FFI::Library
    ffi_lib "gobject-2.0"
    attach_function :g_type_init, [], :void
  end

  public
  class GType
    def self.init; Lib::g_type_init; end
  end
end
module GI
  private

  module Lib
    extend FFI::Library
    ffi_lib "girepository-1.0"

    enum :GIRepositoryLoadFlags, [:LAZY, (1<<0)]
    attach_function :g_irepository_get_default, [], :pointer
    attach_function :g_irepository_require,
      [:pointer, :string, :string, :GIRepositoryLoadFlags, :pointer],
      :pointer
    attach_function :g_irepository_get_n_infos, [:pointer, :string], :int
    attach_function :g_irepository_get_info,
      [:pointer, :string, :int], :pointer

    # g_base_info
    enum :GIInfoType, [
      :INVALID,
      :FUNCTION,
      :CALLBACK,
      :STRUCT,
      :BOXED,
      :ENUM,
      :FLAGS,
      :OBJECT,
      :INTERFACE,
      :CONSTANT,
      :ERROR_DOMAIN,
      :UNION,
      :VALUE,
      :SIGNAL,
      :VFUNC,
      :PROPERTY,
      :FIELD,
      :ARG,
      :TYPE,
      :UNRESOLVED
    ]

    attach_function :g_base_info_get_type, [:pointer], :GIInfoType
    attach_function :g_base_info_get_name, [:pointer], :string
    attach_function :g_base_info_get_namespace, [:pointer], :string
    attach_function :g_base_info_is_deprecated, [:pointer], :int

    # g_function_info
    attach_function :g_function_info_get_symbol, [:pointer], :string
  end

  public

  class Repository

    def self.get_default
      @@singleton ||= Repository.new(Lib::g_irepository_get_default)
    end

    def get_n_infos namespace
      Lib.g_irepository_get_n_infos @gobj, namespace
    end

    def require namespace, version
      err = FFI::MemoryPointer.new :pointer
      res = Lib.g_irepository_require @gobj, namespace, version, 0, err
      unless err.get_pointer(0).address == 0
	# TODO: Interpret err.
	raise "Unable to load namespace #{namespace}"
      end
      p res
    end

    def get_info namespace, i
      ptr = Lib.g_irepository_get_info @gobj, namespace, i
      case Lib.g_base_info_get_type ptr
      when :FUNCTION
	return FunctionInfo.new(ptr)
      else
	return BaseInfo.new(ptr)
      end
    end

    private

    def initialize(gobject)
      @gobj = gobject
    end
  end

  class BaseInfo
    def initialize gobj=nil
      raise "#{self.class} creation not implemeted" if gobj.nil?
      @gobj = gobj
    end
    def name; Lib.g_base_info_get_name @gobj; end
    def type; Lib.g_base_info_get_type @gobj; end
    def namespace; Lib.g_base_info_get_namespace @gobj; end
    def deprecated?; (Lib.g_base_info_is_deprecated @gobj) != 0; end
  end

  class FunctionInfo < BaseInfo
    def symbol; Lib.g_function_info_get_symbol @gobj; end
  end
end

module Main
  def self.infos_for gir, lib
    gir.require lib, nil
    n = gir.get_n_infos lib
    puts "Infos for #{lib}: #{n}"
    (0..(n-1)).each do |i|
      info = gir.get_info lib, i
      case info.type
      when :FUNCTION
	puts "FunctionInfo: #{info.name}; #{info.namespace}; #{info.deprecated?}; #{info.symbol}"
      else
	puts "Info: #{info.name}; #{info.type}; #{info.namespace}; #{info.deprecated?}."
      end
    end
  end

  def self.run
    GLib::GType.init

    gir = GI::Repository.get_default
    p gir
    self.infos_for gir, 'Gtk'
  end
end

Main.run
