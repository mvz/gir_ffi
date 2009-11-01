require 'ffi'

module GLib
  extend FFI::Library

  class GType
    extend FFI::Library
    ffi_lib "gobject-2.0"
    attach_function :g_type_init, [], :void
    def self.init; g_type_init; end
  end
end
module GObjectIntrospection
  extend FFI::Library

  ffi_lib "girepository-1.0"

  class Repository
    extend FFI::Library

    attach_function :g_irepository_get_default, [], :pointer

    def self.get_default
      @@singleton ||= Repository.new(g_irepository_get_default)
    end

    private

    def initialize(gobject)
      @gobj = gobject
    end
  end
end

GLib::GType.init

gir = GObjectIntrospection::Repository.get_default
p gir
