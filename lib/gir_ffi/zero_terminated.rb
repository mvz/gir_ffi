# frozen_string_literal: true

module GirFFI
  # Represents a null-terminated array.
  class ZeroTerminated
    include Enumerable

    attr_reader :element_type

    def initialize(elm_t, ptr)
      @element_type = elm_t
      @ptr = ptr
    end

    def to_ptr
      @ptr
    end

    def self.from(type, arg)
      new type, InPointer.from_array(type, arg)
    end

    def self.wrap(type, arg)
      new type, arg
    end

    def each
      return if @ptr.null?

      offset = 0
      while (val = read_value(offset))
        offset += ffi_type_size
        yield val
      end
    end

    def ==(other)
      to_a == other.to_a
    end

    private

    def read_value(offset)
      val = ArrayElementConvertor.new(element_type, @ptr + offset).to_ruby_value
      val unless null_value? val
    end

    def ffi_type
      @ffi_type ||= TypeMap.type_specification_to_ffi_type element_type
    end

    def ffi_type_size
      @ffi_type_size ||= FFI.type_size(ffi_type)
    end

    def null_check_strategy
      @null_check_strategy ||=
        if ffi_type == :pointer
          :nil
        elsif ffi_type.is_a? Symbol
          :numeric
        elsif ffi_type < GirFFI::ClassBase # rubocop:disable Lint/DuplicateBranch
          :nil
        elsif ffi_type.singleton_class.include? GirFFI::EnumBase
          :enum
        end
    end

    def null_value?(val)
      case null_check_strategy
      when :enum
        ffi_type.to_native(val, nil) == 0
      when :nil
        val.nil?
      else
        val == 0
      end
    end
  end
end
