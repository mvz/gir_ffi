module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ICallableInfo needed by GirFFI
    module ICallableInfo
      def argument_ffi_types
        args.map { |arg| arg.to_ffitype }
      end

      def return_ffi_type
        return_type.to_ffitype
      end

      # TODO: Move to extension just for ICallbackInfo
      def to_ffitype
        Builder.build_class(self)::Callback
      end
    end
  end
end

GObjectIntrospection::ICallableInfo.send :include, GirFFI::InfoExt::ICallableInfo
