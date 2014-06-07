module GObject
  # Module for attaching functions from the gobject library
  module Lib
    extend FFI::Library
    ffi_lib "gobject-2.0"
    attach_function :g_type_init, [], :void
  end
end
