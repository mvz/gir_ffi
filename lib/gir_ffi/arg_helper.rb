# frozen_string_literal: true
require 'gir_ffi/allocation_helper'
require 'gir_ffi/builder'
require 'gir_ffi/glib_error'
require 'gir_ffi/object_store'

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
      unless arr.size == size
        raise ArgumentError, "#{name} should have size #{size}"
      end
    end

    def self.cast_from_pointer(type, it)
      case type
      when :utf8, :filename
        it.to_utf8
      when :gint32, :gint8
        cast_pointer_to_int32 it
      when Class
        type.wrap it
      when :guint32
        it.address
      when Array
        main_type, subtype = *type
        raise "Unexpected main type #{main_type}" if main_type != :pointer
        case subtype
        when Array
          container_type, *element_type = *subtype
          raise "Unexpected container type #{container_type}" if container_type != :ghash
          GLib::HashTable.wrap(element_type, it)
        else
          raise "Unexpected subtype #{subtype}"
        end

      else
        raise "Don't know how to cast #{type}"
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
  end
end
