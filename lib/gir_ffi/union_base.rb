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
  end
end

