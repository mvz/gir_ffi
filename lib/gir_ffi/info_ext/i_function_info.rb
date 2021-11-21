# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IFunctionInfo needed by GirFFI
    module IFunctionInfo
      def argument_ffi_types
        super.tap do |types|
          types.unshift :pointer if method?
          types << :pointer if throws?
        end
      end

      def return_ffi_type
        return_type.to_ffi_type
      end

      def full_name
        if method?
          "#{container.full_name}##{safe_name}"
        elsif container
          "#{container.full_name}.#{safe_name}"
        else
          "#{safe_namespace}.#{safe_name}"
        end
      end
    end
  end
end

GObjectIntrospection::IFunctionInfo.include GirFFI::InfoExt::IFunctionInfo
