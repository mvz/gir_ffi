require 'ffi'

module GirFFI
  module LibC
    extend FFI::Library
    ffi_lib FFI::Library::LIBC
    
    attach_function :malloc, [:size_t], :pointer
    attach_function :calloc, [:size_t], :pointer
    attach_function :free, [:pointer], :void
  end
end
