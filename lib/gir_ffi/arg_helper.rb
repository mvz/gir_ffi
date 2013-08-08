require 'gir_ffi/allocation_helper'
require 'gir_ffi/callback_helper'
require 'gir_ffi/builder'

module GirFFI
  module ArgHelper
    OBJECT_STORE = {}

    POINTER_SIZE = FFI.type_size(:pointer)

    SIMPLE_G_TYPES = [
      :gint8, :gint16, :gint, :gint32, :gint64,
      :guint8, :guint16, :guint32, :guint64,
      :gfloat, :gdouble
    ]

    def self.ptr_to_typed_array type, ptr, size
      return [] if ptr.nil? or ptr.null?

      case type
      when Class
        ptr_to_interface_array type, ptr, size
      when Module
        ptr_to_enum_array type, ptr, size
      when Array
        ptr_to_interface_pointer_array type[1], ptr, size
      when :utf8
        ptr_to_utf8_array ptr, size
      else
        ffi_type = TypeMap.map_basic_type type
        ptr.send "get_array_of_#{ffi_type}", 0, size
      end
    end

    def self.ptr_to_utf8_array ptr, size
      ptrs = ptr.read_array_of_pointer(size)
      ptrs.map { |pt| ptr_to_utf8 pt }
    end

    def self.ptr_to_interface_array klass, ptr, size
      struct_size = klass::Struct.size
      size.times.map do |idx|
        klass.wrap(ptr + struct_size * idx)
      end
    end

    def self.ptr_to_interface_pointer_array klass, ptr, size
      ptrs = ptr.read_array_of_pointer(size)
      ptrs.map do |optr|
        klass.wrap(optr)
      end
    end

    def self.ptr_to_enum_array enum, ptr, size
      ptr.get_array_of_int32(0, size).map {|val| enum[val] }
    end

    if RUBY_VERSION < "1.9"
      def self.ptr_to_utf8 ptr
        ptr.null? ? nil : ptr.read_string
      end
    else
      def self.ptr_to_utf8 ptr
        ptr.null? ? nil : ptr.read_string.force_encoding("utf-8")
      end
    end

    def self.ptr_to_utf8_length ptr, len
      ptr.null? ? nil : ptr.read_string(len)
    end

    def self.check_error errpp
      err = GLib::Error.wrap(errpp.read_pointer)
      raise err.message if err
    end

    def self.check_fixed_array_size size, arr, name
      unless arr.size == size
        raise ArgumentError, "#{name} should have size #{size}"
      end
    end

    def self.object_pointer_to_object optr
      gtype = GObject.type_from_instance_pointer optr
      wrap_object_pointer_by_gtype optr, gtype
    end

    def self.wrap_object_pointer_by_gtype optr, gtype
      return nil if optr.null?
      klass = Builder.build_by_gtype gtype
      klass.direct_wrap optr
    end

    def self.cast_from_pointer type, it
      case type
      when :utf8, :filename
        ptr_to_utf8 it
      when :gint32
        cast_pointer_to_int32 it
      else
        # FIXME: Only handles symbolic types.
        it.address
      end
    end

    def self.cast_uint32_to_int32 val
      if val >= 0x80000000
        -(0x100000000-val)
      else
        val
      end
    end

    def self.cast_pointer_to_int32 ptr
      cast_uint32_to_int32(ptr.address & 0xffffffff)
    end
  end
end
