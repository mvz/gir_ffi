module GirFFI
  # Base module for all generated GLib types.
  module TypeBase
    def gir_ffi_builder
      const_get :GIR_FFI_BUILDER
    end

    def gir_info
      const_get :GIR_INFO
    end
  end
end
