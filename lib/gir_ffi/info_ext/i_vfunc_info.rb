module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IVFuncInfo needed by GirFFI
    module IVFuncInfo
      def argument_ffi_types
        args.map { |arg| arg.to_callback_ffitype }
      end

      def return_ffi_type
        return_type.to_callback_ffitype
      end
    end
  end
end

GObjectIntrospection::IVFuncInfo.send :include, GirFFI::InfoExt::IVFuncInfo
