# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IValueInfo needed by GirFFI
    module IValueInfo
      def constant_name
        upcased_name = name.upcase
        if upcased_name =~ /^[0-9]/
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

GObjectIntrospection::IValueInfo.send :include, GirFFI::InfoExt::IValueInfo
