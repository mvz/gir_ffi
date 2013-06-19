module GirFFI
  module InfoExt
    module IStructInfo
      def to_ffitype
        to_type::Struct
      end
    end
  end
end

GObjectIntrospection::IStructInfo.send :include, GirFFI::InfoExt::IStructInfo
