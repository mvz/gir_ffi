# frozen_string_literal: true

require "gir_ffi/registered_type_base"
require "gir_ffi/method_setup"
require "gir_ffi/instance_method_setup"

module GirFFI
  # Base module for modules representing GLib interfaces.
  module InterfaceBase
    include RegisteredTypeBase
    include MethodSetup
    include InstanceMethodSetup

    def setup_and_call(method, arguments, &block)
      method_name = setup_method method.to_s
      raise NoMethodError, "undefined method `#{method}' for #{self}" unless method_name

      send method_name, *arguments, &block
    end

    # TODO: Unify with implementation in ObjectBase
    def copy_value_to_pointer(value, pointer, offset = 0)
      pointer.put_pointer offset, value.to_ptr
    end

    def wrap(ptr)
      ptr.to_object
    end

    def to_ffi_type
      :pointer
    end

    def to_callback_ffi_type
      :pointer
    end
  end
end
