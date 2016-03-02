# frozen_string_literal: true
require 'gir_ffi/registered_type_base'

module GirFFI
  # Base module for modules representing GLib interfaces.
  module InterfaceBase
    include RegisteredTypeBase

    def setup_and_call(method, arguments, &block)
      method_name = setup_method method.to_s
      unless method_name
        raise NoMethodError, "undefined method `#{method}' for #{self}"
      end
      send method_name, *arguments, &block
    end

    def setup_instance_method(name)
      gir_ffi_builder.setup_instance_method name
    end

    def setup_method(name)
      gir_ffi_builder.setup_method name
    end

    def wrap(ptr)
      ptr.to_object
    end

    def to_ffi_type
      :pointer
    end
  end
end
