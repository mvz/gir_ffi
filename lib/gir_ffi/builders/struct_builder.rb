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
        # HACK: Inheritance chain is not expressed in GObject's code correctly.
        return GObject::ObjectClass if info.full_type_name == "GObject::InitiallyUnownedClass"
        return parent_field_type.tag_or_class if info.gtype_struct?
        return BoxedBase if GObject.type_fundamental(info.gtype) == GObject::TYPE_BOXED

        StructBase
      end

      def parent_field_type
        fields.first.field_type
      end
    end
  end
end
