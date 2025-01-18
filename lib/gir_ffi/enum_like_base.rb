# frozen_string_literal: true

require "gir_ffi/registered_type_base"
require "gir_ffi/method_setup"

module GirFFI
  # Base module for enums and flags.
  module EnumLikeBase
    include FFI::DataConverter
    include RegisteredTypeBase
    include MethodSetup

    def wrap(arg)
      from_native arg, nil
    end

    def to_int(arg)
      to_native arg, nil
    end

    def size
      native_type.size
    end

    def copy_value_to_pointer(value, pointer, offset = 0)
      pointer.put_int32 offset, to_native(value, nil)
    end

    def get_value_from_pointer(pointer, offset)
      from_native pointer.get_int32(offset), nil
    end

    def setup_and_call(method, arguments, &)
      result = setup_method method.to_s

      raise "Unable to set up method #{method} in #{self}" unless result

      send(method, *arguments, &)
    end

    def to_ffi_type
      self
    end

    def to_callback_ffi_type
      :int32
    end
  end
end
