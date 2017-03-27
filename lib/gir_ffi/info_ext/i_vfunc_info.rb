# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IVFuncInfo needed by GirFFI
    # TODO: Merge implementation with ICallbackInfo and ISignalInfo extensions.
    module IVFuncInfo
      def argument_ffi_types
        args.map(&:to_callback_ffi_type).tap do |types|
          types << :pointer if throws?
        end
      end

      def return_ffi_type
        return_type.to_callback_ffi_type
      end

      def invoker_name
        invoker && invoker.name
      end

      def has_invoker?
        invoker
      end
    end
  end
end

GObjectIntrospection::IVFuncInfo.send :include, GirFFI::InfoExt::IVFuncInfo
