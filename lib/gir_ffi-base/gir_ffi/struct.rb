module GirFFI
  class Struct < FFI::Struct
    extend FFI::DataConverter

    def self.native_type
      FFI::Type::Struct.new(self)
    end

    def self.to_native value, context
      value
    end

    def self.from_native value, context
      value
    end

    def self.copy_value_to_pointer value, pointer
      pointer.put_bytes 0, value.to_ptr.read_bytes(size), 0, size
    end

    def self.get_value_from_pointer pointer
      pointer.to_ptr
    end
  end
end
