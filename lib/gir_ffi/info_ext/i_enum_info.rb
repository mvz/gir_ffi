module GirFFI
  module InfoExt
    module IEnumInfo
      def to_ffitype
        to_type::Enum
      end
    end
  end
end

GObjectIntrospection::IEnumInfo.send :include, GirFFI::InfoExt::IEnumInfo
