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
        offset += FFI.type_size(:int32)
        yield val
      end
    end

    private

    def read_value offset
      val = @ptr.get_int32(offset)
      return val unless val == 0
    end
  end
end

