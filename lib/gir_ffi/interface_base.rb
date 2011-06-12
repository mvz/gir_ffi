module GirFFI
  module InterfaceBase
    def _builder
      self.const_get :GIR_FFI_BUILDER
    end

    def _setup_instance_method name
      _builder.setup_instance_method name
    end
  end
end

