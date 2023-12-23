# frozen_string_literal: true

module GirFFI
  # The InPointer module handles conversion from ruby types to pointers for
  # arguments with direction :in. This is used for arguments that are
  # arrays, strings, or interfaces.
  module InPointer
    def self.from_array(type, ary)
      return unless ary

      case type
      when Symbol
        from_simple_type_array type, ary
      when Module
        from_module_type_array type, ary
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
      when :gfloat, :gdouble, :gint64, :guint64
        from_basic_type type, val
      when :gint32, :guint32, :gint8, :GType
        FFI::Pointer.new val
      when GirFFI::EnumLikeBase
        FFI::Pointer.new type[val]
      when Module, :void
        val.to_ptr
      else
        raise NotImplementedError, type
      end
    end

    def self.from_utf8(str)
      return unless str

      ptr = FFI::MemoryPointer.from_string(str)
      ptr.autorelease = false
      ptr
    end

    class << self
      private

      def from_basic_type(type, value)
        ffi_type = TypeMap.type_specification_to_ffi_type type
        FFI::MemoryPointer.new(ffi_type).tap do |block|
          block.autorelease = false
          block.send :"put_#{ffi_type}", 0, value
        end
      end

      def from_simple_type_array(type, ary)
        case type
        when :utf8, :filename
          from_utf8_array ary
        when :gboolean
          from_boolean_array ary
        when :guint8
          from_char_array ary
        else
          from_basic_type_array type, ary
        end
      end

      def from_module_type_array(type, ary)
        return from_gvalue_array(type, ary) if type == GObject::Value

        case type
        when GirFFI::EnumLikeBase
          from_enum_array type, ary
        when GirFFI::RegisteredTypeBase
          from_struct_array type, ary
        else
          raise NotImplementedError, type
        end
      end

      def from_utf8_array(ary)
        from_basic_type_array :pointer, ary.map { |str| from_utf8 str }
      end

      def from_boolean_array(ary)
        from_basic_type_array :int, ary.map { |val| val ? 1 : 0 }
      end

      def from_char_array(ary)
        ary = ary.bytes if ary.is_a? String
        from_basic_type_array :int8, ary
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

      def from_basic_type_array(type, ary)
        ffi_type = TypeMap.type_specification_to_ffi_type type
        type_size = FFI.type_size(ffi_type)
        FFI::MemoryPointer.new(type_size * (ary.length + 1)).tap do |block|
          block.autorelease = false
          block.send :"put_array_of_#{ffi_type}", 0, ary
        end
      end
    end
  end
end
