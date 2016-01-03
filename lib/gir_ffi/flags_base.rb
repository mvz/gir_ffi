require 'gir_ffi/registered_type_base'

module GirFFI
  # Base module for flags.
  module FlagsBase
    include FFI::DataConverter
    include RegisteredTypeBase

    def native_type
      self::BitMask.native_type
    end

    def to_native(value, context)
      case value
      when Symbol
        value = { value => true }
      end
      self::BitMask.to_native(value, context)
    end

    def from_native(*args)
      self::BitMask.from_native(*args)
    end

    def [](arg)
      self::BitMask[arg]
    end

    def wrap(arg)
      self[arg]
    end

    def from(arg)
      self[arg]
    end

    def copy_value_to_pointer(value, pointer)
      pointer.put_int32 0, to_native(value, nil)
    end

    def get_value_from_pointer(pointer, offset)
      from_native pointer.get_int32(offset), nil
    end

    def setup_and_call(method, arguments, &block)
      result = setup_method method.to_s

      unless result
        raise "Unable to set up method #{method} in #{self}"
      end

      send method, *arguments, &block
    end

    def to_ffi_type
      self
    end

    def setup_method(name)
      gir_ffi_builder.setup_method name
    end
  end
end
