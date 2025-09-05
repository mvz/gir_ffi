# frozen_string_literal: true

require "ffi"

module GirFFI
  # Library of libc functions.
  module LibC
    extend FFI::Library

    ffi_lib FFI::Library::LIBC

    attach_function :malloc, [:size_t], :pointer
    attach_function :free, [:pointer], :void
  end
end
