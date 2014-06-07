module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IArgInfo needed by GirFFI
    module IArgInfo
      def to_ffitype
        return :pointer if direction != :in
        argument_type.to_ffitype
      end

      def to_callback_ffitype
        return :pointer if direction != :in
        argument_type.to_callback_ffitype
      end
    end
  end
end

GObjectIntrospection::IArgInfo.send :include, GirFFI::InfoExt::IArgInfo
