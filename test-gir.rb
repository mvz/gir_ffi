require 'ffi'

module GLib
  private
  module Lib
    extend FFI::Library
    ffi_lib "gobject-2.0"
    attach_function :g_type_init, [], :void
  end

  public
  module GType
    def self.init; Lib::g_type_init; end
  end
end

module GIRepository
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
    attach_function :g_base_info_is_deprecated, [:pointer], :bool

    # g_function_info
    attach_function :g_function_info_get_symbol, [:pointer], :string
    # TODO: return type is bitwise-or-ed enum
    attach_function :g_function_info_get_flags, [:pointer], :int

    # IStructInfo
    attach_function :g_struct_info_get_n_fields, [:pointer], :int
    attach_function :g_struct_info_get_field, [:pointer, :int], :pointer
    attach_function :g_struct_info_get_n_methods, [:pointer], :int
    attach_function :g_struct_info_get_method, [:pointer, :int], :pointer
    attach_function :g_struct_info_find_method, [:pointer, :string], :pointer
    attach_function :g_struct_info_get_size, [:pointer], :int
    attach_function :g_struct_info_get_alignment, [:pointer], :int
    attach_function :g_struct_info_is_gtype_struct, [:pointer], :bool

  end

  public

  class IRepository

    def self.get_default
      @@singleton ||= IRepository.new(Lib::g_irepository_get_default)
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
	return IFunctionInfo.new(ptr)
      when :STRUCT
	return IStructInfo.new(ptr)
      else
	return IBaseInfo.new(ptr)
      end
    end

    private

    def initialize(gobject)
      @gobj = gobject
    end
  end

  class IBaseInfo
    def initialize gobj=nil
      raise "#{self.class} creation not implemeted" if gobj.nil?
      @gobj = gobj
    end
    def name; Lib.g_base_info_get_name @gobj; end
    def type; Lib.g_base_info_get_type @gobj; end
    def namespace; Lib.g_base_info_get_namespace @gobj; end
    def deprecated?; Lib.g_base_info_is_deprecated @gobj; end
    def to_s
      s = "#{type} #{name}"
      s << ", DEPRECATED" if deprecated? 
      s
    end
  end

  class IStructInfo < IBaseInfo
    def self.build_array_method elementname
      define_method "#{elementname}s" do
	(0..((send "n_#{elementname}s") - 1)).map do |i|
	  send elementname, i
	end
      end
    end

    def n_fields; Lib.g_struct_info_get_n_fields @gobj; end
    def field i; IFieldInfo.new(Lib.g_struct_info_get_field @gobj, i); end

    build_array_method :field

    def n_methods; Lib.g_struct_info_get_n_methods @gobj; end
    def method i; IFunctionInfo.new(Lib.g_struct_info_get_method @gobj, i); end

    build_array_method :method

    def find_method; Lib.g_struct_info_find_method @gobj; end
    def size; Lib.g_struct_info_get_size @gobj; end
    def alignment; Lib.g_struct_info_get_alignment @gobj; end
    def gtype_struct?; Lib.g_struct_info_is_gtype_struct @gobj; end


    def to_s
      s = super.to_s
      s << ", size = #{size}, alignment = #{alignment}"
      s << ", is #{'not ' unless gtype_struct?}a gtype struct"
      s << ", fields: #{n_fields}, methods: #{n_methods}"
      s << "\n FIELDS: " << fields.map {|f| f.name}.join(", ") if n_fields > 0
      s << "\n METHODS: " << methods.map {|m| m.name}.join(", ") if n_methods > 0
      s
    end
  end

  class IFunctionInfo < IBaseInfo
    def symbol; Lib.g_function_info_get_symbol @gobj; end
    def flags; Lib.g_function_info_get_flags @gobj; end

    def to_s
      s = super.to_s
      f = flags
      s << ", symbol = #{symbol}"
      s << ", IS_METHOD" if f & (1 << 0) != 0
      s << ", IS_CONSTRUCTOR" if f & (1 << 1) != 0
      s << ", IS_GETTER" if f & (1 << 2) != 0
      s << ", IS_SETTER" if f & (1 << 3) != 0
      s << ", WRAPS_VFUNC" if f & (1 << 4) != 0
      s << ", THROWS" if f & (1 << 5) != 0
      s
    end
  end

  class IFieldInfo < IBaseInfo
  end

end

module Main
  def self.infos_for gir, lib
    gir.require lib, nil
    n = gir.get_n_infos lib
    puts "Infos for #{lib}: #{n}"
    (0..(n-1)).each do |i|
      info = gir.get_info lib, i
      puts info
    end
  end

  def self.run
    GLib::GType.init

    gir = GIRepository::IRepository.get_default
    p gir
    self.infos_for gir, 'Gtk'
  end
end

Main.run
