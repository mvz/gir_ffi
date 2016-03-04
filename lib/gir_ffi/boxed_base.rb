# frozen_string_literal: true
require 'gir_ffi/class_base'

module GirFFI
  # Base class for generated classes representing boxed types.
  class BoxedBase < ClassBase
    extend FFI::DataConverter

    def self.native_type
      FFI::Type::Struct.new(self::Struct)
    end

    def self.to_ffi_type
      self
    end

    # NOTE: Needed for JRuby's FFI
    def self.to_native(value, _context)
      value.struct
    end

    def self.get_value_from_pointer(pointer, offset)
      pointer + offset
    end

    def self.copy_value_to_pointer(value, pointer, offset = 0)
      size = self::Struct.size
      bytes = if value
                value.to_ptr.read_bytes(size)
              else
                "\x00" * size
              end
      pointer.put_bytes offset, bytes, 0, size
    end

    def initialize
      @struct = self.class::Struct.new
      gtype = self.class.gtype
      if GObject.type_fundamental(gtype) == GObject::TYPE_BOXED
        ObjectSpace.define_finalizer self, self.class.make_finalizer(@struct, gtype)
      end
    end

    def self.make_finalizer(struct, gtype)
      proc do
        ptr = struct.to_ptr
        ptr.autorelease = false
        GObject.boxed_free gtype, struct.to_ptr
      end
    end
  end
end
