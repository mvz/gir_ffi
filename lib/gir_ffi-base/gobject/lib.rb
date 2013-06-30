require 'gir_ffi-base/gir_ffi/library'

module GObject
  module Lib
    extend GirFFI::Library
    ffi_lib "gobject-2.0"
    attach_function :g_type_init, [], :void
  end
end
