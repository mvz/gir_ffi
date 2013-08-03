module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout and :out.
  class InOutPointer < FFI::Pointer
    attr_reader :value_type

    def initialize value, type
      @value_type = type

      value = adjust_value_in value

      ptr = AllocationHelper.safe_malloc(FFI.type_size value_ffi_type)
      ptr.send "put_#{value_ffi_type}", 0, value

      super ptr
    end

    private :initialize

    def to_value
      adjust_value_out self.send("get_#{value_ffi_type}", 0)
    end

    def value_ffi_type
      @value_ffi_type ||= case value_type
                          when :gboolean
                            :int
                          else
                            TypeMap.type_specification_to_ffitype value_type
                          end
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
        value ? 1 : 0
      else
        value || nil_value
      end
    end

    def adjust_value_out value
      case value_type
      when :gboolean
        value != 0
      else
        value
      end
    end

    def nil_value
      value_ffi_type == :pointer ? nil : 0
    end
  end
end
