module GirFFI
  module Builder
    module Type

      # Implements the creation of classes representing types with layout,
      # i.e., :union, :struct, :object.
      module WithLayout
        private

        def setup_layout
          spec = layout_specification
          @structklass.class_eval { layout(*spec) }
        end

        def layout_specification
          fields = info.fields

          if fields.empty?
            if parent
              return [:parent, superclass.const_get(:Struct), 0]
            else
              return [:dummy, :char, 0]
            end
          end

          fields.inject([]) do |spec, finfo|
            spec +
              [ finfo.name.to_sym,
                itypeinfo_to_ffitype_for_struct(finfo.field_type),
                finfo.offset ]
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
