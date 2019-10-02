# frozen_string_literal: true

require 'gir_ffi/builder_helper'

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IRegisteredTypeInfo needed by GirFFI
    module IRegisteredTypeInfo
      def to_ffi_type
        to_type.to_ffi_type
      end

      def to_callback_ffi_type
        to_type.to_callback_ffi_type
      end

      def to_type
        Builder.build_class self
      end

      def find_instance_method(method)
        info = find_method method
        return info if info&.method?
      end

      def find_method(_method)
        raise 'Must be overridden in subclass'
      end
    end
  end
end

GObjectIntrospection::IRegisteredTypeInfo.include GirFFI::InfoExt::IRegisteredTypeInfo
