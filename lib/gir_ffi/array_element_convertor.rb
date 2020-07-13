# frozen_string_literal: true

module GirFFI
  # The ArrayElementConvertor class handles conversion from C array elements to
  # ruby values
  class ArrayElementConvertor
    attr_reader :value_type, :pointer

    def initialize(type, ptr)
      @value_type = type
      @pointer = ptr
    end

    def to_ruby_value
      bare_value = to_value
      case value_type
      when :utf8
        bare_value.to_utf8
      when Array
        value_type[1].wrap bare_value
      when Class
        value_type.wrap bare_value
      else
        bare_value
      end
    end

    private

    def to_value
      case value_ffi_type
      when Module
        value_ffi_type.get_value_from_pointer(pointer, 0)
      when Symbol
        pointer.send("get_#{value_ffi_type}", 0)
      else
        raise NotImplementedError
      end
    end

    def value_ffi_type
      @value_ffi_type ||= TypeMap.type_specification_to_ffi_type value_type
    end
  end
end
