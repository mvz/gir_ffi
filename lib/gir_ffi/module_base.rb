module GirFFI
  # Base module for modules representing GLib namespaces.
  module ModuleBase
    def method_missing method, *arguments, &block
      result = setup_method method.to_s
      return super unless result
      send method, *arguments, &block
    end

    def const_missing classname
      load_class(classname) || super
    end

    def setup_class classname
      gir_ffi_builder.build_namespaced_class classname.to_s
    end

    alias_method :load_class, :setup_class

    def gir_ffi_builder
      const_get :GIR_FFI_BUILDER
    end

    def setup_method name
      gir_ffi_builder.setup_method name
    end
  end
end
