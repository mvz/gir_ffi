module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout and :out.
  class InOutPointer < FFI::Pointer
    attr_reader :value_type

    def initialize value, type
      @ffi_type = TypeMap.type_specification_to_ffitype type
      @value_type = type

      value = adjust_value_in value

      ptr = AllocationHelper.safe_malloc(FFI.type_size @ffi_type)
      ptr.send "put_#{@ffi_type}", 0, value

      super ptr
    end

    private :initialize

    def to_value
      value = self.send "get_#{@ffi_type}", 0
      adjust_value_out value
    end

    def self.for type
      if Array === type
        return self.new nil, *type
      end
      self.new nil, type
    end

    def self.from type, value
      self.new value, type
    end

    private

    def adjust_value_in value
      case @value_type
      when :gboolean
        (value ? 1 : 0)
      else
        value || nil_value
      end
    end

    def nil_value
      @ffi_type == :pointer ? nil : 0
    end

    def adjust_value_out value
      case @value_type
      when :gboolean
        (value != 0)
      else
        value
      end
    end
  end
end
