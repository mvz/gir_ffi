module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IUnresolvedInfo needed by GirFFI
    module IUnresolvedInfo
      def to_ffi_type
        :pointer
      end
    end
  end
end

GObjectIntrospection::IUnresolvedInfo.send :include, GirFFI::InfoExt::IUnresolvedInfo
