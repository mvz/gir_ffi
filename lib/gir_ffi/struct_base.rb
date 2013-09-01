module GirFFI
  class StructBase < ClassBase
    extend FFI::DataConverter
    def self.native_type
      self::Struct.native_type
    end

    def self.to_native value, context
      self::Struct.new(value.to_ptr)
    end

    def self.to_ffitype
      self
    end

    def self.copy_value_to_pointer value, pointer
      self::Struct.copy_value_to_pointer value, pointer
    end

    def self.get_value_from_pointer pointer
      self::Struct.get_value_from_pointer pointer
    end
  end
end
