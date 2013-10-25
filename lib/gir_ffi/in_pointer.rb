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
        if type == GObject::Value
          from_gvalue_array type, ary
        else
          from_struct_array type, ary
        end
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
      def from_object obj
        obj.to_ptr if obj
      end

      def from_closure_data obj
        FFI::Pointer.new(obj.object_id).tap {|ptr|
          ArgHelper::OBJECT_STORE[ptr.address] = obj }
      end

      private

      def from_utf8_array ary
        from_basic_type_array :pointer, ary.map {|str| from_utf8 str}
      end

      def from_boolean_array ary
        from_basic_type_array :int, ary.map {|val| val ? 1 : 0}
      end

      def from_interface_pointer_array ary
        from_basic_type_array :pointer, ary.map {|ifc| ifc.to_ptr}
      end

      def from_gvalue_array type, ary
        ary = ary.map do |it|
          if it.is_a? GObject::Value
            it
          else
            GObject::Value.wrap_ruby_value it
          end
        end
        from_struct_array type, ary
      end

      def from_struct_array type, ary
        ffi_type = TypeMap.type_specification_to_ffitype type
        type_size = FFI.type_size(ffi_type)
        ptr = AllocationHelper.safe_malloc ary.length * type_size
        ary.each_with_index do |item, idx|
          type.copy_value_to_pointer item, ptr, idx * type_size
        end
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
        ffi_type = TypeMap.type_specification_to_ffitype type
        ary = ary.dup << null_value(ffi_type)
        type_size = FFI.type_size(ffi_type)
        block = AllocationHelper.safe_malloc type_size * ary.length
        block.send "put_array_of_#{ffi_type}", 0, ary
        new block
      end

      def null_value ffi_type
        ffi_type == :pointer ? nil : 0
      end
    end
  end
end
