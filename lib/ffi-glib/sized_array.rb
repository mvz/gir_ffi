module GLib
  # Class representing an array with a determined size
  class SizedArray
    include Enumerable
    attr_reader :element_type, :size

    def initialize element_type, size, pointer
      @element_type = element_type
      @size = size
      @pointer = pointer
    end

    def to_ptr
      @pointer
    end

    def each &block
      # TODO: Move implementation from GirFFI::ArgHelper to here.
      # While doing so, the implentation could also become a real iterator
      arr = GirFFI::ArgHelper.ptr_to_typed_array(@element_type, @pointer, @size)
      if block_given?
        arr.each(&block)
      else
        arr.each
      end
    end

    def self.wrap element_type, size, pointer
      new element_type, size, pointer unless pointer.null?
    end

    class << self
      def from element_type, size, it
        case it
        when FFI::Pointer
          wrap element_type, size, it
        when self
          from_sized_array size, it
        else
          from_enumerable element_type, size, it
        end
      end

      private

      def from_sized_array size, sized_array
        check_size(size, sized_array.size)
        sized_array
      end

      def from_enumerable element_type, size, arr
        check_size(size, arr.size)
        ptr = GirFFI::InPointer.from_array element_type, arr
        self.wrap element_type, arr.size, ptr
      end

      def check_size(expected_size, size)
        if expected_size > 0 && size != expected_size
          raise ArgumentError, "Expected size #{expected_size}, got #{size}"
        end
      end
    end
  end
end
