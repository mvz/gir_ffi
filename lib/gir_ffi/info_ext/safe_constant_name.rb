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

GObjectIntrospection::ICallbackInfo.send :include, GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::IConstantInfo.send :include, GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::IRegisteredTypeInfo.send :include, GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::ISignalInfo.send :include, GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::IVFuncInfo.send :include, GirFFI::InfoExt::SafeConstantName
