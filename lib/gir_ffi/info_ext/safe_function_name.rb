# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extension module provinding a #safe_name method suitable for functions.
    module SafeFunctionName
      def safe_name
        name = self.name
        return '_' if name.empty?

        name
      end
    end
  end
end

GObjectIntrospection::IFunctionInfo.include GirFFI::InfoExt::SafeFunctionName
