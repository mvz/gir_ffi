# frozen_string_literal: true

require 'gir_ffi/registered_type_base'
require 'gir_ffi/method_setup'

module GirFFI
  # Base module for enums and flags.
  module EnumLikeBase
    include FFI::DataConverter
    include RegisteredTypeBase
    include MethodSetup

    def wrap(arg)
      self[arg]
    end

    def from(arg)
      self[arg]
    end

    def size
      native_type.size
    end

    def copy_value_to_pointer(value, pointer)
      pointer.put_int32 0, to_native(value, nil)
    end

    def get_value_from_pointer(pointer, offset)
      from_native pointer.get_int32(offset), nil
    end

    def setup_and_call(method, arguments, &block)
      result = setup_method method.to_s

      raise "Unable to set up method #{method} in #{self}" unless result

      send method, *arguments, &block
    end

    def to_ffi_type
      self
    end

    def to_callback_ffi_type
      :int32
    end
  end
end
