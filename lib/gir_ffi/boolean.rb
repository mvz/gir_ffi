# frozen_string_literal: true

require "ffi"

module GirFFI
  # Class representing a boolean (natively, an int).
  class Boolean
    extend FFI::DataConverter
    native_type FFI::Type::INT

    NATIVE_TRUE = 1
    NATIVE_FALSE = 0
    FROM_NATIVE = { NATIVE_FALSE => false, NATIVE_TRUE => true }.freeze

    def self.from_native(value, _context)
      FROM_NATIVE.fetch(value)
    end

    def self.to_native(value, _context)
      value ? NATIVE_TRUE : NATIVE_FALSE
    end

    def self.size
      FFI.type_size FFI::Type::INT
    end

    def self.copy_value_to_pointer(value, pointer, offset = 0)
      pointer.put_int offset, to_native(value, nil)
    end

    def self.get_value_from_pointer(pointer, offset)
      from_native pointer.get_int(offset), nil
    end
  end
end
