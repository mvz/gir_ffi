require 'gir_ffi/builder/argument'
require 'gir_ffi/variable_name_generator'

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

        def setup_field_accessors
          info.fields.each do |finfo|
            unless info.find_method finfo.name
              @klass.class_eval getter_def(finfo)
            end
            @klass.class_eval setter_def(finfo) if finfo.writable?
          end
        end

        # TODO: Extract to new FieldBuilder class.
        def getter_builder finfo
          type = finfo.field_type
          klass = Builder::ReturnValue.builder_for_field_getter type
          vargen = VariableNameGenerator.new
          klass.new vargen, finfo.name, type, nil
        end

        def getter_def finfo
          builder = getter_builder finfo
          name = finfo.name

          return <<-CODE
          def #{name}
            #{builder.cvar} = @struct[#{name.to_sym.inspect}]
            #{builder.post.join("\n")}
            #{builder.retval}
          end
          CODE
        end

        def setter_builder finfo
          type = finfo.field_type
          vargen = VariableNameGenerator.new
          Builder::InArgument.builder_for vargen, "value", type, lib
        end

        def setter_def finfo
          builder = setter_builder finfo
          builder.prepare
          name = finfo.name

          return <<-CODE
          def #{name}= #{builder.inarg}
            #{builder.pre.join("\n")}
            @struct[#{name.to_sym.inspect}] = #{builder.callarg}
          end
          CODE
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
