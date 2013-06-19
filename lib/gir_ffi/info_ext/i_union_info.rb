module GirFFI
  module InfoExt
    module IUnionInfo
      def to_ffitype
        # TODO: It would make more sense if it were called Union
        to_type::Struct
      end
    end
  end
end

GObjectIntrospection::IUnionInfo.send :include, GirFFI::InfoExt::IUnionInfo
