module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ICallbackInfo needed by GirFFI
    module ICallbackInfo
      def to_ffitype
        Builder.build_class(self)
      end

      def argument_ffi_types
        args.map { |arg| arg.to_callback_ffitype }
      end

      def return_ffi_type
        result = return_type.to_callback_ffitype
        # FIXME: Should this be in ITypeInfo#to_callback_ffitype?
        if result == GLib::Boolean
          :bool
        else
          result
        end
      end
    end
  end
end

GObjectIntrospection::ICallbackInfo.send :include, GirFFI::InfoExt::ICallbackInfo
