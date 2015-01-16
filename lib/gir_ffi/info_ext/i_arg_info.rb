module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IArgInfo needed by GirFFI
    module IArgInfo
      # @deprecated Use #to_ffi_type instead. Will be removed in 0.8.0.
      def to_ffitype
        to_ffi_type
      end

      def to_ffi_type
        return :pointer if direction != :in
        argument_type.to_ffi_type
      end

      # @deprecated Use #to_callback_ffi_type instead. Will be removed in 0.8.0.
      def to_callback_ffitype
        to_callback_ffi_type
      end

      def to_callback_ffi_type
        return :pointer if direction != :in
        argument_type.to_callback_ffi_type
      end
    end
  end
end

GObjectIntrospection::IArgInfo.send :include, GirFFI::InfoExt::IArgInfo
