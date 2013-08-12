require 'gir_ffi/builder_helper'
require 'gir_ffi/info_ext/safe_constant_name'

module GirFFI
  module InfoExt
    module IRegisteredTypeInfo
      include SafeConstantName

      def full_type_name
        "::#{safe_namespace}::#{name}"
      end

      def to_ffitype
        to_type.to_ffitype
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

GObjectIntrospection::IRegisteredTypeInfo.send :include, GirFFI::InfoExt::IRegisteredTypeInfo

