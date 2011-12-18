module GirFFI
  # The InPointer class handles conversion from ruby types to pointers for
  # arguments with direction :in. This is used for arguments that are
  # arrays, strings, or interfaces.
  class InPointer < FFI::Pointer
    def self.from_array type, ary
      return nil if ary.nil?
      return from_utf8_array ary if type == :utf8
      return from_interface_pointer_array ary if type == :interface_pointer

      return from_basic_type_array type, ary
    end

    def self.from type, val
      return nil if val.nil?
      case type
      when :utf8
        from_utf8 val
      when :gint32, :gint8
        self.new val
      else
        raise NotImplementedError
      end
    end

    class << self

      private

      def from_utf8_array ary
        ptr_ary = ary.map {|str| self.from :utf8, str}
        ptr_ary << nil
        self.from_array :pointer, ptr_ary
      end

      def from_interface_pointer_array ary
        ptr_ary = ary.map {|ifc| ifc.to_ptr}
        ptr_ary << nil
        self.from_array :pointer, ptr_ary
      end

      def from_utf8 str
        len = str.bytesize
        ptr = AllocationHelper.safe_malloc(len + 1).write_string(str).put_char(len, 0)
        self.new ptr
      end

      def from_basic_type_array type, ary
        ffi_type = TypeMap.map_basic_type type
        block = ArgHelper.allocate_array_of_type ffi_type, ary.length
        block.send "put_array_of_#{ffi_type}", 0, ary

        self.new block
      end

    end
  end
end
