# frozen_string_literal: true

require 'gir_ffi/method_setup'

module GirFFI
  # Base module for modules representing GLib namespaces.
  module ModuleBase
    include MethodSetup

    def method_missing(method, *arguments, &block)
      result = setup_method method.to_s
      return super unless result

      send method, *arguments, &block
    end

    def respond_to_missing?(method, *)
      gir_ffi_builder.method_available? method
    end

    def const_missing(classname)
      load_class(classname)
    end

    def load_class(classname)
      gir_ffi_builder.build_namespaced_class classname.to_s
    end

    def gir_ffi_builder
      self::GIR_FFI_BUILDER
    end
  end
end
