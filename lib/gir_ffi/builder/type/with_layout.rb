require 'gir_ffi/builder/field'
require 'gir_ffi/info_ext/i_field_info'

module GirFFI
  module Builder
    module Type

      # Implements the creation of classes representing types with layout,
      # i.e., :union, :struct, :object.
      # Note: This module depends on the additional inclusion of
      # WithMethods.
      module WithLayout
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
          info.fields.map { |finfo| finfo.layout_specification }.flatten(1)
        end

        def layout_specification
          spec = base_layout_specification
          if spec.empty?
            dummy_layout_specification
          else
            spec
          end
        end

        def setup_accessors_for_field_info finfo
          builder = Builder::Field.new(finfo, lib)
          unless has_instance_method finfo.name
            @klass.class_eval builder.getter_def
          end
          @klass.class_eval builder.setter_def if finfo.writable?
        end

        def setup_field_accessors
          info.fields.each do |finfo|
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
end
