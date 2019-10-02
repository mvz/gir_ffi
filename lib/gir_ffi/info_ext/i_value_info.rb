# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IValueInfo needed by GirFFI
    module IValueInfo
      def constant_name
        upcased_name = name.upcase
        if /^[0-9]/.match?(upcased_name)
          "VALUE_#{upcased_name}"
        else
          upcased_name
        end
      end

      def to_callback_ffi_type
        return :pointer if direction != :in

        argument_type.to_callback_ffi_type
      end
    end
  end
end

GObjectIntrospection::IValueInfo.include GirFFI::InfoExt::IValueInfo
