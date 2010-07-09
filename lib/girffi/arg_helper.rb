require 'girffi/allocation_helper'

module GirFFI
  module ArgHelper
    def self.object_to_inptr obj
      return obj.to_ptr if obj.respond_to? :to_ptr
      obj
    end

    def self.int_to_inoutptr val
      ptr = AllocationHelper.safe_malloc FFI.type_size(:int)
      ptr.write_int val
      return ptr
    end

    def self.string_array_to_inoutptr ary
      return nil if ary.nil?
      ptrs = ary.map {|str|
	# TODO: use malloc and write terminating null byte ourselves.
	AllocationHelper.safe_calloc(str.bytesize + 1).write_string str
      }
      block = AllocationHelper.safe_malloc FFI.type_size(:pointer) * ptrs.length
      block.write_array_of_pointer ptrs
      argv = AllocationHelper.safe_malloc FFI.type_size(:pointer)
      argv.write_pointer block
      argv
    end

    # Converts an outptr to an int, then frees the outptr.
    def self.outptr_to_int ptr
      value = ptr.read_int
      LibC.free ptr
      value
    end

    # Converts an outptr to a string array, then frees the outptr.
    def self.outptr_to_string_array ptr, size
      return nil if ptr.nil?

      block = ptr.read_pointer
      LibC.free ptr

      return nil if block.null?

      ptrs = block.read_array_of_pointer(size)
      LibC.free block

      ary = ptrs.map {|p| p.null? ? nil : p.read_string}
      ptrs.each {|p| LibC.free p unless p.null? }

      ary
    end
  end
end
