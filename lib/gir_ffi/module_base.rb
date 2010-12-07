module GirFFI
  module ModuleBase
    def method_missing method, *arguments, &block
      result = gir_ffi_builder.setup_function method.to_s
      return super unless result
      self.send method, *arguments, &block
    end

    def gir_ffi_builder
      self.const_get :GIR_FFI_BUILDER
    end
  end
end
