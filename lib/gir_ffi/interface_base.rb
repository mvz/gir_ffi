module GirFFI
  module InterfaceBase
    # @deprecated Compatibility function. Remove in version 0.5.0.
    def _builder
      gir_ffi_builder
    end

    def gir_ffi_builder
      self.const_get :GIR_FFI_BUILDER
    end

    # @deprecated Compatibility function. Remove in version 0.5.0.
    def _setup_instance_method name
      setup_instance_method name
    end

    def setup_instance_method name
      _builder.setup_instance_method name
    end
  end
end

