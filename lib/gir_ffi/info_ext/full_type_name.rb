# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extension module provinding a #full_type_name method suitable for
    # callbacks, constants and registered types. Signals and vfuncs need a
    # different implementation.
    module FullTypeName
      def full_type_name
        "#{safe_namespace}::#{safe_name}"
      end
    end
  end
end

GObjectIntrospection::ICallbackInfo.send :include, GirFFI::InfoExt::FullTypeName
GObjectIntrospection::IConstantInfo.send :include, GirFFI::InfoExt::FullTypeName
GObjectIntrospection::IRegisteredTypeInfo.send :include, GirFFI::InfoExt::FullTypeName
