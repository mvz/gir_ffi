module GirFFI
  module TypeBase
    def gir_ffi_builder
      self.const_get :GIR_FFI_BUILDER
    end
  end
end
