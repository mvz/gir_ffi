# frozen_string_literal: true
module GirFFI
  module StructLikeBase
    def native_type
      FFI::Type::Struct.new(self::Struct)
    end

    def to_ffi_type
      self
    end

    # NOTE: Needed for JRuby's FFI
    def to_native(value, _context)
      value.struct
    end

    def get_value_from_pointer(pointer, offset)
      pointer + offset
    end

    def size
      self::Struct.size
    end

    def copy_value_to_pointer(value, pointer, offset = 0)
      size = self::Struct.size
      bytes = if value
                value.to_ptr.read_bytes(size)
              else
                "\x00" * size
              end
      pointer.put_bytes offset, bytes, 0, size
    end

    # Create an unowned copy of the struct represented by val
    def copy_from(val)
      copy(from(val)).tap { |it| it && it.to_ptr.autorelease = false }
    end

    # Wrap an owned copy of the struct represented by val
    def wrap_copy(val)
      copy wrap(val)
    end

    # Create a copy of the struct represented by val
    def copy(val)
      return unless val
      new.tap { |copy| copy_value_to_pointer(val, copy.to_ptr) }
    end
  end
end
