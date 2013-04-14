module GirFFI
  module InfoExt
    # Extension module provinding a #safe_name method suitable for types.
    module SafeConstantName
      def safe_name
        name.gsub(/^./) do |char|
          case char
          when "_"
            "Private___"
          else
            char.upcase
          end
        end
      end
    end
  end
end

GObjectIntrospection::IRegisteredTypeInfo.send :include, GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::ICallbackInfo.send :include, GirFFI::InfoExt::SafeConstantName
GObjectIntrospection::IConstantInfo.send :include, GirFFI::InfoExt::SafeConstantName

