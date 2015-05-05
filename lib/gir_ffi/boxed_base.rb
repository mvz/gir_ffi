require 'gir_ffi/class_base'

module GirFFI
  # Base class for generated classes representing boxed types.
  class BoxedBase < ClassBase
    extend FFI::DataConverter

    def self.native_type
      FFI::Type::Struct.new(self::Struct)
    end

    # @deprecated Use #to_ffi_type instead. Will be removed in 0.8.0.
    def self.to_ffitype
      to_ffi_type
    end

    def self.to_ffi_type
      self
    end

    def self.to_native value, _context
      value.struct
    end

    def self.get_value_from_pointer pointer
      pointer.to_ptr
    end

    def self.copy_value_to_pointer value, pointer, offset = 0
      size = self::Struct.size
      pointer.put_bytes offset, value.to_ptr.read_bytes(size), 0, size
    end

    def self._allocate
      obj = _real_new
      obj.instance_variable_set :@struct, self::Struct.new
      obj
    end
  end
end
