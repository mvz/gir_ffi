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

    # TODO: Find method to directly copy bytes, rather than reading and
    # putting them.
    def self.copy_value_to_pointer value, pointer, offset=0
      pointer.put_bytes offset, value.to_ptr.read_bytes(size), 0, size
    end

    def self.get_value_from_pointer pointer
      pointer.to_ptr
    end
  end
end
