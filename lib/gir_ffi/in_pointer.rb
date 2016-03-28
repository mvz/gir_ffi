# frozen_string_literal: true
module GirFFI
  # The InPointer module handles conversion from ruby types to pointers for
  # arguments with direction :in. This is used for arguments that are
  # arrays, strings, or interfaces.
  module InPointer
    def self.from_array(type, ary)
      return unless ary
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
        main_type, sub_type = *type
        raise "Unexpected main type #{main_type}" if main_type != :pointer
        from_pointer_array sub_type, ary
      else
        raise NotImplementedError, type
      end
    end

    def self.from(type, val)
      return unless val
      case type
      when :utf8, :filename
        from_utf8 val
      when :gint32, :guint32, :gint8, :GType
        FFI::Pointer.new val
      when Class, :void
        val.to_ptr
      when Module
        FFI::Pointer.new type[val]
      else
        raise NotImplementedError, type
      end
    end

    class << self
      private

      def from_utf8_array(ary)
        from_basic_type_array :pointer, ary.map { |str| from_utf8 str }
      end

      def from_boolean_array(ary)
        from_basic_type_array :int, ary.map { |val| val ? 1 : 0 }
      end

      def from_pointer_array(type, ary)
        from_basic_type_array :pointer, ary.map { |elem| from type, elem }
      end

      def from_gvalue_array(type, ary)
        ary = ary.map do |it|
          if it.is_a? GObject::Value
            it
          else
            GObject::Value.wrap_ruby_value it
          end
        end
        from_struct_array type, ary
      end

      def from_struct_array(type, ary)
        ffi_type = TypeMap.type_specification_to_ffi_type type
        type_size = FFI.type_size(ffi_type)
        length = ary.length

        ptr = FFI::MemoryPointer.new type_size * (length + 1)
        ptr.autorelease = false
        ary.each_with_index do |item, idx|
          type.copy_value_to_pointer item, ptr, idx * type_size
        end
        ptr
      end

      def from_enum_array(type, ary)
        from_basic_type_array :int32, ary.map { |sym| type.to_native sym, nil }
      end

      public

      def from_utf8(str)
        return unless str
        ptr = FFI::MemoryPointer.from_string(str)
        ptr.autorelease = false
        ptr
      end

      private

      def from_basic_type_array(type, ary)
        ffi_type = TypeMap.type_specification_to_ffi_type type
        type_size = FFI.type_size(ffi_type)
        block = FFI::MemoryPointer.new type_size * (ary.length + 1)
        block.autorelease = false
        block.send "put_array_of_#{ffi_type}", 0, ary
        block
      end
    end
  end
end
