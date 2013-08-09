module GirFFI
  module InterfaceBase
    def gir_ffi_builder
      self.const_get :GIR_FFI_BUILDER
    end

    def setup_instance_method name
      gir_ffi_builder.setup_instance_method name
    end

    def wrap ptr
      ptr.to_object
    end
  end
end
