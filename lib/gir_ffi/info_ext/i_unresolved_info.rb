module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IUnresolvedInfo needed by GirFFI
    module IUnresolvedInfo
      # @deprecated Use #to_ffi_type instead. Will be removed in 0.8.0.
      def to_ffitype
        to_ffi_type
      end

      def to_ffi_type
        :pointer
      end
    end
  end
end

GObjectIntrospection::IUnresolvedInfo.send :include, GirFFI::InfoExt::IUnresolvedInfo
