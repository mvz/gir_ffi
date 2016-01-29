require 'ffi/bit_masks'

# NOTE: Monkey-patch BitMask to work on JRuby.
FFI::BitMasks::BitMask.class_eval do
  def reference_required?
    false
  end
end

module GObject
  # Module for attaching functions from the gobject library
  module Lib
    extend FFI::Library
    extend FFI::BitMasks
    ffi_lib 'gobject-2.0'
    attach_function :g_type_init, [], :void
  end
end
