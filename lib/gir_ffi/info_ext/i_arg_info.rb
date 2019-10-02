# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IArgInfo needed by GirFFI
    module IArgInfo
      def to_ffi_type
        return :pointer if direction != :in

        argument_type.to_ffi_type
      end

      def to_callback_ffi_type
        return :pointer if direction != :in

        argument_type.to_callback_ffi_type
      end
    end
  end
end

GObjectIntrospection::IArgInfo.include GirFFI::InfoExt::IArgInfo
