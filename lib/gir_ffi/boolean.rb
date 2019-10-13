# frozen_string_literal: true

require "ffi"

module GirFFI
  # Class representing a boolean (natively, an int).
  class Boolean
    extend FFI::DataConverter
    native_type FFI::Type::INT

    FROM_NATIVE = { 0 => false, 1 => true }.freeze
    TO_NATIVE = FROM_NATIVE.invert

    def self.from_native(value, _context)
      FROM_NATIVE.fetch(value)
    end

    def self.to_native(value, _context)
      TO_NATIVE.fetch(value ? true : false)
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
