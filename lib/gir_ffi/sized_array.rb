# frozen_string_literal: true

require "gir_ffi/array_element_convertor"

module GirFFI
  # Class representing an array with a determined size
  class SizedArray
    include Enumerable

    attr_reader :element_type, :size

    def initialize(element_type, size, pointer)
      @element_type = element_type
      @size = size
      @pointer = pointer
    end

    def to_ptr
      @pointer
    end

    def index(idx)
      convertor = ArrayElementConvertor.new element_type, @pointer + idx * element_size
      convertor.to_ruby_value
    end

    def each
      size.times do |idx|
        yield index(idx)
      end
    end

    def ==(other)
      to_a.eql? other.to_a
    end

    def size_in_bytes
      size * element_size
    end

    def self.get_value_from_pointer(pointer, offset)
      pointer + offset
    end

    def self.copy_value_to_pointer(value, pointer, offset = 0)
      size = value.size_in_bytes
      pointer.put_bytes(offset, value.to_ptr.read_bytes(size))
    end

    def self.wrap(element_type, size, pointer)
      new element_type, size, pointer unless pointer.null?
    end

    private

    def element_ffi_type
      @element_ffi_type ||= TypeMap.type_specification_to_ffi_type element_type
    end

    def element_size
      @element_size ||= FFI.type_size element_ffi_type
    end

    class << self
      def from(element_type, size, item)
        return unless item

        case item
        when FFI::Pointer
          wrap element_type, size, item
        when self
          from_sized_array size, item
        else
          from_enumerable element_type, size, item
        end
      end

      def copy_from(element_type, size, enumerable)
        return unless enumerable

        arr = enumerable.to_a
        case element_type
        when Array
          _main_type, sub_type = *element_type
          arr = arr.map { |it| sub_type.copy_from it }
        end

        from_enumerable element_type, size, arr
      end

      private

      def from_sized_array(size, sized_array)
        check_size size, sized_array.size
        sized_array
      end

      def from_enumerable(element_type, expected_size, arr)
        size = arr.size
        check_size expected_size, size
        ptr = InPointer.from_array element_type, arr
        wrap element_type, size, ptr
      end

      def check_size(expected_size, size)
        return if expected_size == -1
        return if size == expected_size

        raise ArgumentError, "Expected size #{expected_size}, got #{size}"
      end
    end
  end
end
