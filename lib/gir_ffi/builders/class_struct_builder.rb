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

      def superclass
        @superclass ||=
          begin
            if info.namespace == "GObject" && info.name == "InitiallyUnownedClass"
              GObject::ObjectClass
            else
              parent_field = info.fields.first
              parent_info = parent_field.field_type.interface
              Builder.build_class parent_info
            end
          end
      end

      def layout_superclass
        GirFFI::Struct
      end
    end
  end
end
