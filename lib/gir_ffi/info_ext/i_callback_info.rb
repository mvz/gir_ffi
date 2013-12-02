module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ICallbackInfo needed by GirFFI
    module ICallbackInfo
      def to_ffitype
        Builder.build_class(self)
      end

      def return_ffi_type
        return_type.to_callback_ffitype
      end
    end
  end
end

GObjectIntrospection::ICallbackInfo.send :include, GirFFI::InfoExt::ICallbackInfo

