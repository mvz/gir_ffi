module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IVFuncInfo needed by GirFFI
    # TODO: Merge implementation with ICallbackInfo and ISignalInfo extensions.
    module IVFuncInfo
      def argument_ffi_types
        args.map { |arg| arg.to_callback_ffitype }
      end

      def return_ffi_type
        result = return_type.to_callback_ffitype
        if result == GLib::Boolean
          :bool
        else
          result
        end
      end
    end
  end
end

GObjectIntrospection::IVFuncInfo.send :include, GirFFI::InfoExt::IVFuncInfo
