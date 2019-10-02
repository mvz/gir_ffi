# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extension module provinding a #safe_name method suitable for types.
    module SafeConstantName
      def safe_name
        name.tr('-', '_').gsub(/^./) do |char|
          case char
          when '_'
            'Private___'
          else
            char.upcase
          end
        end
      end
    end
  end
end

GObjectIntrospection::ICallbackInfo.include GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::IConstantInfo.include GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::IRegisteredTypeInfo.include GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::ISignalInfo.include GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::IVFuncInfo.include GirFFI::InfoExt::SafeConstantName
