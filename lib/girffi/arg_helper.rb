require 'girffi/allocation_helper'

module GirFFI
  module ArgHelper
    def self.object_to_inptr obj
      return obj.to_ptr if obj.respond_to? :to_ptr
      return nil if obj.nil?
      FFI::Pointer.new(obj.object_id)
    end

    def self.int_to_inoutptr val
      ptr = AllocationHelper.safe_malloc FFI.type_size(:int)
      ptr.write_int val
      return ptr
    end

    def self.string_array_to_inoutptr ary
      return nil if ary.nil?

      ptrs = ary.map {|str|
	len = str.bytesize
	AllocationHelper.safe_malloc(len + 1).write_string(str).put_char(len, 0)
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

      ptrs.map { |p| p.null? ? nil : (str = p.read_string; LibC.free p; str) }
    end

    def self.mapped_callback_args prc=nil, &block
      return prc if FFI::Function === prc
      if prc.nil?
	return nil if block.nil?
	prc = block
      end
      return Proc.new do |*args|
	mapped = args.map {|arg|
	  if FFI::Pointer === arg
	    begin
	      ObjectSpace._id2ref arg.address
	    rescue RangeError
	      arg
	    end
	  else
	    arg
	  end
	}
	prc.call(*mapped)
      end
    end
  end
end
