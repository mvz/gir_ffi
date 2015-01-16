require 'gir_ffi/builder_helper'

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IRegisteredTypeInfo needed by GirFFI
    module IRegisteredTypeInfo
      # @deprecated Use #to_ffi_type instead. Will be removed in 0.8.0.
      def to_ffitype
        to_ffi_type
      end

      def to_ffi_type
        to_type.to_ffi_type
      end

      def to_type
        Builder.build_class self
      end

      def find_instance_method method
        info = find_method method
        return info if info && info.method?
      end
    end
  end
end

GObjectIntrospection::IRegisteredTypeInfo.send :include,
                                               GirFFI::InfoExt::IRegisteredTypeInfo
