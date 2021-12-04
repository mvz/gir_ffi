# frozen_string_literal: true

require "gir_ffi/builders/registered_type_builder"
require "gir_ffi/builders/struct_like"
require "gir_ffi/struct_base"

module GirFFI
  module Builders
    # Implements the creation of a class representing a Struct.
    class StructBuilder < RegisteredTypeBuilder
      include StructLike

      def initialize(info, superclass: nil)
        @superclass = superclass
        super info
      end

      def superclass
        @superclass ||= if info.gtype_struct?
                          gtype_struct_parent
                        elsif GObject.type_fundamental(info.gtype) == GObject::TYPE_BOXED
                          BoxedBase
                        else
                          StructBase
                        end
      end

      private

      def layout_superclass
        GirFFI::Struct
      end

      def klass
        @klass ||= get_or_define_class(namespace_module, @classname) { superclass }
      end

      def parent_info
        @parent_info ||= parent_field_type&.interface
      end

      def parent_field_type
        fields.first&.field_type
      end

      def gtype_struct_parent
        full_name = info.full_name
        if full_name == "GObject::InitiallyUnownedClass"
          GObject::ObjectClass
        else
          raise "Unable to calculate parent class for #{full_name}" unless parent_info

          Builder.build_class parent_info
        end
      end
    end
  end
end
