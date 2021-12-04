# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extension module provinding a #full_name method suitable for
    # callbacks, constants and registered types. Signals and vfuncs need a
    # different implementation.
    #
    module FullTypeName
      def full_name
        "#{safe_namespace}::#{safe_name}"
      end
    end
  end
end

GObjectIntrospection::ICallbackInfo.include GirFFI::InfoExt::FullTypeName
GObjectIntrospection::IConstantInfo.include GirFFI::InfoExt::FullTypeName
GObjectIntrospection::IRegisteredTypeInfo.include GirFFI::InfoExt::FullTypeName
