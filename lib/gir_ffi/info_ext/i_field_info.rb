# frozen_string_literal: true

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IFieldInfo needed by GirFFI
    module IFieldInfo
      def layout_specification
        [name.to_sym, field_type.to_ffi_type, offset]
      end

      def related_array_length_field
        index = field_type.array_length
        container.fields[index] if index > -1
      end
    end
  end
end

GObjectIntrospection::IFieldInfo.include GirFFI::InfoExt::IFieldInfo
