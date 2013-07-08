module GirFFI
  module InfoExt
    module IObjectInfo
      def to_ffitype
        :pointer
      end
    end
  end
end

GObjectIntrospection::IObjectInfo.send :include, GirFFI::InfoExt::IObjectInfo
