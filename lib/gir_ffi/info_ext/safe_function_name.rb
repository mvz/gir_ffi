module GirFFI
  module InfoExt
    module SafeFunctionName
      def safe_name
        name = self.name
        return "_" if name.empty?
        name
      end
    end
  end
end

GObjectIntrospection::IFunctionInfo.send :include, GirFFI::InfoExt::SafeFunctionName
