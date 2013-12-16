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
        offset += FFI.type_size(ffi_type)
        yield wrap_value(val)
      end
    end

    def ==(other)
      self.to_a == other.to_a
    end

    private

    def read_value offset
      val = @ptr.send(getter_method, offset)
      return val unless is_null_value?(val)
    end

    def getter_method
      @getter_method ||= "get_#{ffi_type}"
    end

    def wrap_value(val)
      if complex_element_type?
        element_class.wrap val
      else
        val
      end
    end

    def ffi_type
      @ffi_type ||= TypeMap.type_specification_to_ffitype element_type
    end

    def complex_element_type?
      Array === element_type
    end

    def element_class
      @element_class ||= element_type.last
    end

    def is_null_value? value
      if ffi_type == :pointer
        value.null?
      else
        value == 0
      end
    end
  end
end

