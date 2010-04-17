module GirFFI
  module Helper
    module Arg
      def self.int_to_inoutptr val
	ptr = FFI::MemoryPointer.new(:int)
	ptr.write_int val
	return ptr
      end

      def self.string_array_to_inoutptr ary
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
	block = ptr.read_pointer
	ptrs = block.read_array_of_pointer(size)
	return ptrs.map {|p| p.null? ? nil : p.read_string}
      end
    end
  end
end
