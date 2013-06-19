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
        to_type
      end

      def to_type
        Builder.build_class self
      end
    end
  end
end

GObjectIntrospection::IRegisteredTypeInfo.send :include, GirFFI::InfoExt::IRegisteredTypeInfo

