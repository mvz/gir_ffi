# frozen_string_literal: true
require 'gir_ffi/lib_c'

module GirFFI
  # Helper module providing a safe allocation method that raises an exception
  # if memory cannot be allocated.
  module AllocationHelper
    # NOTE: It would be preferable to use FFI::MemoryPointer.new(size), but
    # there is a bug in FFI which means this gives a problem:
    #   # let ptr be a pointer not allocated by FFI.
    #   ptr2 = FFI::MemoryPointer.new(1)
    #   ptr.put_pointer ptr2 # This raises an out-of-bounds error.
    # This occurs in method_int8_arg_and_out_callee
    def self.safe_malloc(size)
      ptr = LibC.malloc size
      raise NoMemoryError if ptr.null?
      ptr
    end

    def self.allocate_for_type(type)
      type_size = FFI.type_size type
      safe_malloc(type_size)
    end

    def self.allocate_clear_for_type(type)
      ptr = FFI::MemoryPointer.new(type)
      ptr.clear
      ptr.autorelease = false
      ptr
    end
  end
end
