module GirFFI
  # Base module for all generated GLib types.
  module TypeBase
    def gir_ffi_builder
      self.const_get :GIR_FFI_BUILDER
    end

    def gir_info
      self.const_get :GIR_INFO
    end
  end
end
