require 'gir_ffi/builders/field_builder'

module GirFFI
  module Builders
    # Implements the creation of classes representing types with layout,
    # i.e., :union, :struct, :object.
    # Note: This module depends on the additional inclusion of
    # WithMethods.
    module WithLayout
      def layout_specification
        spec = base_layout_specification
        if spec.empty?
          dummy_layout_specification
        else
          spec
        end
      end

      private

      def setup_layout
        spec = layout_specification
        @structklass.class_eval { layout(*spec) }
      end

      def dummy_layout_specification
        if parent
          [:parent, superclass.const_get(:Struct), 0]
        else
          [:dummy, :char, 0]
        end
      end

      def base_layout_specification
        fields.map { |finfo| finfo.layout_specification }.flatten(1)
      end

      def setup_accessors_for_field_info finfo
        FieldBuilder.new(finfo).build
      end

      def setup_field_accessors
        fields.each do |finfo|
          setup_accessors_for_field_info finfo
        end
      end

      def instantiate_class
        @klass = get_or_define_class namespace_module, @classname, superclass
        @structklass = get_or_define_class @klass, :Struct, layout_superclass
        setup_class unless already_set_up
      end
    end
  end
end
