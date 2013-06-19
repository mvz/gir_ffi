module GirFFI
  module InfoExt
    module IObjectInfo
      def to_ffitype
        to_type::Struct
      end
    end
  end
end

GObjectIntrospection::IObjectInfo.send :include, GirFFI::InfoExt::IObjectInfo
