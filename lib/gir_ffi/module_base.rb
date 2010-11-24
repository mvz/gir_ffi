module GirFFI
  module ModuleBase
    def method_missing method, *arguments, &block
      result = gir_ffi_builder.setup_function method.to_s
      return super unless result
      self.send method, *arguments, &block
    end

  end
end
