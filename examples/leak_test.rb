# Test program to train Valgrind.
require 'ffi'

module LibC
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  attach_function :malloc, [:size_t], :pointer
end

LibC.malloc 2000
