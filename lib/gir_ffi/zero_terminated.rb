module GirFFI
  # Represents a null-terminated array.
  class ZeroTerminated
    include Enumerable

    attr_reader :element_type

    def initialize elm_t, ptr
      @element_type = elm_t
      @ffi_type = TypeMap.map_basic_type_or_string elm_t
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
        offset += FFI.type_size(@ffi_type)
        yield val
      end
    end

    private

    def read_value offset
      val = @ptr.send("get_#{ffi_type}", offset)
      return val unless val == 0
    end

    def ffi_type
      @ffi_type ||= TypeMap.map_basic_type_or_string element_type
    end
  end
end

