module GirFFI
  module InterfaceBase
    def _builder
      self.const_get :GIR_FFI_BUILDER
    end
  end
end

