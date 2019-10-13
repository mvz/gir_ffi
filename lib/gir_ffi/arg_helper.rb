# frozen_string_literal: true

require "gir_ffi/allocation_helper"
require "gir_ffi/builder"
require "gir_ffi/glib_error"
require "gir_ffi/object_store"

module GirFFI
  # Helper module containing methods used during argument conversion in
  # generated methods.
  module ArgHelper
    OBJECT_STORE = ObjectStore.new

    def self.check_error(errpp)
      err = GLib::Error.wrap(errpp.read_pointer)
      raise GLibError, err if err
    end

    def self.check_fixed_array_size(size, arr, name)
      raise ArgumentError, "#{name} should have size #{size}" unless arr.size.equal? size
    end

    # NOTE: Only used in List, SList and HashTable classes.
    # TODO: Stop using basic types and instead cast type to an ITypeInfo
    # look-alike.
    def self.cast_from_pointer(type, ptr)
      case type
      when Symbol
        cast_from_simple_type_pointer(type, ptr)
      when Class
        type.wrap ptr
      when Array
        cast_from_complex_type_pointer(type, ptr)
      end
    end

    def self.cast_uint32_to_int32(val)
      if val >= 0x80000000
        -(0x100000000 - val)
      else
        val
      end
    end

    def self.cast_pointer_to_int32(ptr)
      cast_uint32_to_int32(ptr.address & 0xffffffff)
    end

    def self.store(obj)
      OBJECT_STORE.store(obj)
    end

    def self.cast_from_simple_type_pointer(type, ptr)
      case type
      when :utf8, :filename
        ptr.to_utf8
      when :gint32, :gint8
        cast_pointer_to_int32 ptr
      when :guint32
        ptr.address
      else
        raise "Don't know how to cast #{type}"
      end
    end

    def self.cast_from_complex_type_pointer(type, ptr)
      main_type, (container_type, *element_type) = *type
      case main_type
      when :pointer
        case container_type
        when :ghash
          return GLib::HashTable.wrap(element_type, ptr)
        end
      end
      raise "Don't know how to cast #{type}"
    end

    private_class_method :cast_from_complex_type_pointer, :cast_from_simple_type_pointer
  end
end
