module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ICallbackInfo needed by GirFFI
    module ICallbackInfo
      # @deprecated Use #to_ffi_type instead. Will be removed in 0.8.0.
      def to_ffitype
        to_ffi_type
      end

      def to_ffi_type
        Builder.build_class(self)
      end

      def argument_ffi_types
        args.map(&:to_callback_ffi_type)
      end

      def return_ffi_type
        return_type.to_callback_ffi_type
      end
    end
  end
end

GObjectIntrospection::ICallbackInfo.send :include, GirFFI::InfoExt::ICallbackInfo
