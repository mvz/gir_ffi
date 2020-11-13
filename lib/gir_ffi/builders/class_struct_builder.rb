# frozen_string_literal: true

require "gir_ffi/builders/struct_builder"

module GirFFI
  module Builders
    # Implements the creation of a class representing a Struct.
    class ClassStructBuilder < RegisteredTypeBuilder
      include StructLike

      def initialize(info, super_class_struct = nil)
        @superclass = super_class_struct
        super info
        raise "Info does not represent gtype_struct" unless info.gtype_struct?
      end

      private

      def superclass
        @superclass ||=
          begin
            full_name = info.full_type_name
            if full_name == "GObject::InitiallyUnownedClass"
              GObject::ObjectClass
            else
              raise "Unable to calculate parent class for #{full_name}" unless parent_info

              Builder.build_class parent_info
            end
          end
      end

      def parent_info
        @parent_info ||=
          begin
            parent_field = info.fields.first
            parent_field.field_type.interface if parent_field
          end
      end

      def layout_superclass
        GirFFI::Struct
      end
    end
  end
end
