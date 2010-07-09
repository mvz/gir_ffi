require 'girffi/libc'

module GirFFI
  module ArgHelper
    def self.object_to_inptr obj
      return obj.to_ptr if obj.respond_to? :to_ptr
      obj
    end

    def self.int_to_inoutptr val
      ptr = FFI::MemoryPointer.new(:int)
      ptr.write_int val
      return ptr
    end

    def self.string_array_to_inoutptr ary
      return nil if ary.nil?
      ptrs = ary.map {|str|
	# TODO: use malloc and write terminating null byte ourselves.
	self.safe_calloc(str.bytesize + 1).write_string str
      }
      block = self.safe_malloc FFI.type_size(:pointer) * ptrs.length
      block.write_array_of_pointer ptrs
      argv = self.safe_malloc FFI.type_size(:pointer)
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

    private

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
