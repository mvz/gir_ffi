module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout and :out.
  #
  # TODO: This has now become a more general extende pointer class and should be renamed.
  class InOutPointer < FFI::Pointer
    attr_reader :value_type

    def initialize type, ptr = nil
      @value_type = type

      ptr ||= AllocationHelper.safe_malloc(value_type_size)
      super ptr
    end

    private :initialize

    # TODO: Rename to get_value
    def to_value
      case value_ffi_type
      when Class
        value_ffi_type.get_value_from_pointer(self)
      when Symbol
        adjust_value_out self.send("get_#{value_ffi_type}", 0)
      else
        raise NotImplementedError
      end
    end

    def set_value value
      value = adjust_value_in value
      case value_ffi_type
      when Class
        value_ffi_type.copy_value_to_pointer(value, self)
      when Symbol
        self.send "put_#{value_ffi_type}", 0, value
      else
        raise NotImplementedError
      end
    end

    def value_ffi_type
      @value_ffi_type ||= TypeMap.type_specification_to_ffitype value_type
    end

    def value_type_size
      @value_type_size ||= FFI.type_size value_ffi_type
    end

    def self.for type
      self.new(type).tap {|ptr| ptr.set_value nil}
    end

    def self.from type, value
      self.new(type).tap {|ptr| ptr.set_value value}
    end

    private

    def adjust_value_in value
      case value_type
      when :gboolean
        value
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
