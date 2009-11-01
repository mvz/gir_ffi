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

    private

    def initialize(gobject)
      @gobj = gobject
    end
  end
end

GLib::GType.init

gir = GI::Repository.get_default
p gir
gir.require "Gtk", nil
puts "Infos for Gtk: #{gir.get_n_infos 'Gtk'}"
