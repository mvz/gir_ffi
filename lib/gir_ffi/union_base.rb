module GirFFI
  class UnionBase < ClassBase
    extend FFI::DataConverter

    def self.native_type
      FFI::Type::Struct.new(self::Struct)
    end

    def self.to_ffitype
      self
    end

    # FIXME: Duplicate of GirFFI::Struct
    def self.get_value_from_pointer pointer
      pointer.to_ptr
    end

    # FIXME: Duplicate of GirFFI::Struct
    def self.copy_value_to_pointer value, pointer, offset=0
      size = self::Struct.size
      pointer.put_bytes offset, value.to_ptr.read_bytes(size), 0, size
    end
  end
end
