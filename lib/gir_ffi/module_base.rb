module GirFFI
  module ModuleBase
    def method_missing method, *arguments, &block
      result = _setup_function method.to_s
      return super unless result
      self.send method, *arguments, &block
    end

    def const_missing classname
      klass = _builder.build_namespaced_class classname.to_s
      return super if klass.nil?
      klass
    end

    def _builder
      self.const_get :GIR_FFI_BUILDER
    end

    def _setup_function name
      _builder.setup_method name
    end
  end
end
