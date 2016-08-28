# frozen_string_literal: true
module GirFFI
  # Base module providing class methods for generated classes representing GLib
  # structs, unions and boxed types.
  module StructLikeBase
    def self.included(base)
      base.extend ClassMethods
    end

    # Class methods for struct-like classes.
    module ClassMethods
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
        bytes = value.to_ptr.read_bytes(size)
        pointer.put_bytes offset, bytes
      end

      # Create an unowned copy of the struct represented by val
      def copy_from(val)
        disown copy from(val)
      end

      # Wrap an owned copy of the struct represented by val
      def wrap_copy(val)
        copy(val)
      end

      # Wrap value and take ownership of it
      def wrap_own(val)
        own wrap(val)
      end

      private

      def own(val)
        val.struct.owned = true if val
        val
      end

      def disown(val)
        val.struct.owned = nil if val
        val
      end

      # Create a copy of the struct represented by val
      def copy(val)
        return unless val
        new.tap do |copy|
          copy_value_to_pointer(val, copy.to_ptr)
        end
      end
    end
  end
end
