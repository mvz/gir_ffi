module GirFFI
  # The InPointer class handles conversion from ruby types to pointers for
  # arguments with direction :in. This is used for arguments that are
  # arrays, strings, or interfaces.
  class InPointer < FFI::Pointer
    def self.from_array type, ary
      return if !ary
      case type
      when :utf8, :filename
        from_utf8_array ary
      when :gboolean
        from_boolean_array ary
      when Symbol
        from_basic_type_array type, ary
      when Class
        from_struct_array type, ary
      when Module
        from_enum_array type, ary
      when Array
        from_interface_pointer_array ary
      else
        raise NotImplementedError, type
      end
    end

    def self.from type, val
      return if !val
      case type
      when :utf8, :filename
        from_utf8 val
      when :gint32, :guint32, :gint8
        self.new val
      when Module
        self.new type[val]
      when :void
        from_object val
      else
        raise NotImplementedError, type
      end
    end

    class << self
      # FIXME: Hideous
      def from_object obj
        return nil if obj.nil?
        return obj.to_ptr if obj.respond_to? :to_ptr

        FFI::Pointer.new(obj.object_id).tap {|ptr|
          ArgHelper::OBJECT_STORE[ptr.address] = obj }
      end

      private

      def from_utf8_array ary
        ptr_ary = ary.map {|str| from_utf8 str}
        ptr_ary << nil
        from_basic_type_array :pointer, ptr_ary
      end

      def from_boolean_array ary
        from_basic_type_array :int, ary.map {|val| val ? 1 : 0}
      end

      def from_interface_pointer_array ary
        ptr_ary = ary.map {|ifc| ifc.to_ptr}
        ptr_ary << nil
        from_basic_type_array :pointer, ptr_ary
      end

      def from_struct_array type, ary
        type_size = type::Struct.size
        length = ary.length

        # TODO: Find method to directly copy bytes, rather than reading and
        # putting them.
        ptr = AllocationHelper.safe_malloc length * type_size
        ary.each_with_index { |item, idx|
          ptr.put_bytes(idx * type_size,
                        item.to_ptr.read_bytes(type_size),
                        0,
                        type_size)
        }
        new ptr
      end

      def from_enum_array type, ary
        from_basic_type_array :int32, ary.map {|sym| type.to_native sym, nil }
      end

      def from_utf8 str
        len = str.bytesize
        ptr = AllocationHelper.safe_malloc(len + 1).write_string(str).put_char(len, 0)
        new ptr
      end

      def from_basic_type_array type, ary
        ffi_type = TypeMap.map_basic_type type
        length = ary.length

        block = ArgHelper.allocate_array_of_type ffi_type, length + 1
        block.send "put_array_of_#{ffi_type}", 0, ary
        block.send("put_#{ffi_type}",
                   length * FFI.type_size(ffi_type),
                   (ffi_type == :pointer ? nil : 0))

        new block
      end
    end
  end
end
