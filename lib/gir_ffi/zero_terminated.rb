module GirFFI
  # Represents a null-terminated array.
  class ZeroTerminated
    include Enumerable

    attr_reader :element_type

    def initialize elm_t, ptr
      @element_type = elm_t
      @ptr = ptr
    end

    def to_ptr
      @ptr
    end

    def self.from type, arg
      self.new type, InPointer.from_array(type, arg)
    end

    def self.wrap type, arg
      self.new type, arg
    end

    def each
      return if @ptr.null?
      offset = 0
      while val = read_value(offset)
        offset += ffi_type_size
        yield wrap_value(val)
      end
    end

    def == other
      self.to_a == other.to_a
    end

    private

    def read_value offset
      val = @ptr.send(getter_method, offset)
      val unless val.zero?
    end

    def getter_method
      @getter_method ||= "get_#{ffi_type}"
    end

    def wrap_value val
      case element_type
      when Array
        element_type.last.wrap val
      when Class
        element_type.wrap val
      else
        val
      end
    end

    def ffi_type
      @ffi_type ||= TypeMap.type_specification_to_ffitype element_type
    end

    def ffi_type_size
      @ffi_type_size ||= FFI.type_size(ffi_type)
    end
  end
end
