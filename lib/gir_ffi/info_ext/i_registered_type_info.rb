require 'gir_ffi/builder_helper'

module GirFFI
  module InfoExt
    module IRegisteredTypeInfo
      def full_type_name
	"::#{safe_namespace}::#{name}"
      end
    end
  end
end

GObjectIntrospection::IRegisteredTypeInfo.send :include, GirFFI::InfoExt::IRegisteredTypeInfo

