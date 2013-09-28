require 'gir_ffi/allocation_helper'
require 'gir_ffi/builder'

module GirFFI
  module ArgHelper
    OBJECT_STORE = {}

    # @deprecated Compatibility function. Remove in 0.7.0.
    def self.ptr_to_utf8 ptr
      ptr.to_utf8
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

    def self.cast_from_pointer type, it
      case type
      when :utf8, :filename
        it.to_utf8
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
