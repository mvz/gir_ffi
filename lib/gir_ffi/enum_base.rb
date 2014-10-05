require 'gir_ffi/registered_type_base'

module GirFFI
  # Base module for enums.
  module EnumBase
    include FFI::DataConverter
    include RegisteredTypeBase

    def native_type
      self::Enum.native_type
    end

    def to_native *args
      self::Enum.to_native(*args)
    end

    def from_native *args
      self::Enum.from_native(*args)
    end

    def [] arg
      self::Enum[arg]
    end

    def wrap arg
      self[arg]
    end

    def from arg
      self[arg]
    end

    def copy_value_to_pointer value, pointer
      pointer.put_int32 0, to_native(value, nil)
    end

    def get_value_from_pointer pointer
      from_native pointer.get_int32(0), nil
    end

    def setup_and_call method, arguments, &block
      result = setup_method method.to_s

      unless result
        raise "Unable to set up method #{method} in #{self}"
      end

      send method, *arguments, &block
    end

    def to_ffitype
      self
    end

    def setup_method name
      gir_ffi_builder.setup_method name
    end
  end
end
