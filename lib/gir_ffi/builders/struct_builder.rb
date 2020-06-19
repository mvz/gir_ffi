# frozen_string_literal: true

require "gir_ffi/builders/registered_type_builder"
require "gir_ffi/builders/struct_like"
require "gir_ffi/struct_base"

module GirFFI
  module Builders
    # Implements the creation of a class representing a Struct.
    class StructBuilder < RegisteredTypeBuilder
      include StructLike

      def layout_superclass
        GirFFI::Struct
      end

      def superclass
        raise "Use ClassStructBuilder to build #{info.full_type_name}" if info.gtype_struct?
        return BoxedBase if GObject.type_fundamental(info.gtype) == GObject::TYPE_BOXED

        StructBase
      end

      def klass
        @klass ||= get_or_define_class(namespace_module, @classname) { superclass }
      end

      def parent_field_type
        fields.first.field_type
      end
    end
  end
end
