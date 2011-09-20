module GObjectIntrospection
  module GObjectLib
    extend FFI::Library
    ffi_lib "gobject-2.0"
    attach_function :g_type_init, [], :void
  end
end
