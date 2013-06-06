module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IFunctionInfo needed by GirFFI
    module IFunctionInfo
      def argument_ffi_types
        super.tap do |types|
          types.unshift :pointer if method?
          types << :pointer if throws?
        end
      end
    end
  end
end

GObjectIntrospection::IFunctionInfo.send :include, GirFFI::InfoExt::IFunctionInfo
