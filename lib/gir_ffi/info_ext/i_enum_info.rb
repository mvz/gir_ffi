module GirFFI
  module InfoExt
    module IEnumInfo
      def to_ffitype
        # TODO: It would make more sense if it were called Enum
        to_type::Enum
      end
    end
  end
end

GObjectIntrospection::IEnumInfo.send :include, GirFFI::InfoExt::IEnumInfo

