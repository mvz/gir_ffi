require 'ffi'

module GirFFI
  module LibC
    extend FFI::Library
    ffi_lib FFI::Library::LIBC
    
    attach_function :malloc, [:size_t], :pointer
    attach_function :calloc, [:size_t], :pointer
    attach_function :free, [:pointer], :void

    def self.safe_calloc size
      ptr = LibC.calloc size
      raise NoMemoryError if ptr.null?
      ptr
    end

    def self.safe_malloc size
      ptr = LibC.malloc size
      raise NoMemoryError if ptr.null?
      ptr
    end
  end
end
