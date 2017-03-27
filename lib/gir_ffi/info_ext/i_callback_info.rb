# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ICallbackInfo needed by GirFFI
    module ICallbackInfo
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
