module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout.
  class InOutPointer < FFI::Pointer
    def initialize ptr, type, ffi_type
      super ptr
      @ffi_type = ffi_type
      @value_type = type
    end

    def to_value
      value = self.send "get_#{@ffi_type}", 0
      adjust_value_out value
    end

    private

    def adjust_value_out value
      case @value_type
      when :gboolean
        (value != 0)
      when :utf8
        ArgHelper.ptr_to_utf8 value
      else
        value
      end
    end

    def self.for type
      ffi_type = type_to_ffi_type type
      ptr = AllocationHelper.safe_malloc(FFI.type_size ffi_type)
      ptr.send "put_#{ffi_type}", 0, 0
      self.new ptr, type, ffi_type
    end

    def self.from type, value
      value = adjust_value_in type, value
      ffi_type = type_to_ffi_type type
      ptr = AllocationHelper.safe_malloc(FFI.type_size ffi_type)
      ptr.send "put_#{ffi_type}", 0, value
      self.new ptr, type, ffi_type
    end

    def self.from_array type, array
      return nil if array.nil?
      ptr = InPointer.from_array(type, array)
      self.from :pointer, ptr
    end

    class << self
      # TODO: Make separate module to hold type info.
      def type_to_ffi_type type
        case type
        when :gboolean
          :int32
        when :utf8
          :pointer
        else
          GirFFI::Builder::TAG_TYPE_MAP[type] || type
        end
      end

      def adjust_value_in type, value
        case type
        when :gboolean
          (value ? 1 : 0)
        when :utf8
          InPointer.from :utf8, value
        else
          value
        end
      end
    end
  end
end

