module GirFFI
  module Helper
    module Arg
      # FIXME: Use FFI::AutoPointer or NiceFFI::OpaqueStruct instead.
      def self.object_to_inptr obj
	return nil if obj.nil?
	return obj.to_ptr if obj.respond_to? :to_ptr
	raise NotImplementedError
      end

      def self.int_to_inoutptr val
	ptr = FFI::MemoryPointer.new(:int)
	ptr.write_int val
	return ptr
      end

      # FIXME: This implementation dumps core if GC runs before using argv.
      def self.string_array_to_inoutptr ary
	return nil if ary.nil?
	ptrs = ary.map {|a| FFI::MemoryPointer.from_string(a)}
	block = FFI::MemoryPointer.new(:pointer, ptrs.length)
	block.write_array_of_pointer ptrs
	argv = FFI::MemoryPointer.new(:pointer)
	argv.write_pointer block
	argv
      end

      def self.outptr_to_int ptr
	return ptr.read_int
      end

      def self.outptr_to_string_array ptr, size
	return nil if ptr.nil?
	block = ptr.read_pointer
	ptrs = block.read_array_of_pointer(size)
	return ptrs.map {|p| p.null? ? nil : p.read_string}
      end
    end
  end
end
