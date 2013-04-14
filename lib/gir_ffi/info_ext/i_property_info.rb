module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IPropertyInfo needed by GirFFI
    module IPropertyInfo
      def getter_name
        name.gsub(/-/, '_')
      end
    end
  end
end

GObjectIntrospection::IPropertyInfo.send :include, GirFFI::InfoExt::IPropertyInfo

