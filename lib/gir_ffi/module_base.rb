module GirFFI
  module ModuleBase
    def method_missing method, *arguments, &block
      result = setup_method method.to_s
      return super unless result
      self.send method, *arguments, &block
    end

    def const_missing classname
      klass = load_class classname
      return super if klass.nil?
      klass
    end

    def load_class classname
      gir_ffi_builder.build_namespaced_class classname.to_s
    end

    def gir_ffi_builder
      self.const_get :GIR_FFI_BUILDER
    end

    def setup_method name
      gir_ffi_builder.setup_method name
    end
  end
end
