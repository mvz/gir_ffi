require 'gir_ffi/allocation_helper'

module GirFFI
  module ArgHelper
    def self.object_to_inptr obj
      return obj.to_ptr if obj.respond_to? :to_ptr
      return nil if obj.nil?
      FFI::Pointer.new(obj.object_id)
    end

    def self.int_array_to_inptr ary
      return nil if ary.nil?

      int_size = FFI.type_size(:int32)
      block = AllocationHelper.safe_malloc int_size * ary.length
      block.write_array_of_int ary

      block
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

      ptr_size = FFI.type_size(:pointer)
      block = AllocationHelper.safe_malloc ptr_size * ptrs.length
      block.write_array_of_pointer ptrs

      argv = AllocationHelper.safe_malloc ptr_size
      argv.write_pointer block
      argv
    end

    def self.double_to_inoutptr val
      ptr = AllocationHelper.safe_malloc FFI.type_size(:double)
      ptr.put_double 0, val
      return ptr
    end

    # Converts an outptr to an int, then frees the outptr.
    def self.outptr_to_int ptr
      value = ptr.read_int
      LibC.free ptr
      value
    end

    # Converts an outptr to a string array, then frees pointers.
    def self.outptr_to_string_array ptr, size
      return nil if ptr.nil?

      block = ptr.read_pointer
      LibC.free ptr

      return nil if block.null?

      ptrs = block.read_array_of_pointer(size)
      LibC.free block

      ptrs.map do |p|
	if p.null?
	  nil
	else
	  p.read_string.tap { LibC.free p }
	end
      end
    end

    # Converts an outptr to a double, then frees the outptr.
    def self.outptr_to_double ptr
      value = ptr.get_double 0
      LibC.free ptr
      value
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

    def self.check_error errpp
      errp = errpp.read_pointer
      raise GError.new(errp)[:message] unless errp.null?
    end

    def self.sink_if_floating gobject
      if GirFFI::GObject.object_is_floating(gobject)
	GirFFI::GObject.object_ref_sink(gobject)
      end
    end

    def self.check_fixed_array_size size, arr, name
      unless arr.size == size
	raise ArgumentError, "#{name} should have size #{size}"
      end
    end
  end
end
