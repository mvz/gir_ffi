module GirFFI
  module InfoExt
    module IPropertyInfo
      def getter_name
        name.gsub /-/, '_'
      end
    end
  end
end

GObjectIntrospection::IPropertyInfo.send :include, GirFFI::InfoExt::IPropertyInfo

