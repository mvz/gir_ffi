module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IFieldInfo needed by GirFFI
    module IFieldInfo
      def layout_specification
        [ name.to_sym,
          field_type.layout_specification_type,
          offset ]
      end
    end
  end
end

GObjectIntrospection::IFieldInfo.send :include, GirFFI::InfoExt::IFieldInfo
