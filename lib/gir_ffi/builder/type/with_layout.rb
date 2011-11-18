require 'gir_ffi/builder/argument'
require 'gir_ffi/variable_name_generator'

module GirFFI
  module Builder
    module Type

      # Implements the creation of classes representing types with layout,
      # i.e., :union, :struct, :object.
      module WithLayout
        # XXX Temporary fix
        class FakeArgumentInfo
          def initialize type
            @type = type
          end

          def return_type
            @type
          end
        end

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
            unless @klass.method_defined? finfo.name
              @klass.class_eval getter_def(finfo)
            end
            @klass.class_eval setter_def(finfo)
          end
        end

        def getter_def finfo
          name = finfo.name
          type = finfo.field_type
          klass = Builder::ReturnValue.builder_for type, false
          fb = VariableNameGenerator.new
          arginfo = FakeArgumentInfo.new type
          builder = klass.new fb, name, arginfo, nil
          return <<-CODE
          def #{name}
            #{builder.cvar} = @struct[#{name.to_sym.inspect}]
            #{builder.post.join("\n")}
            #{builder.retval}
          end
          CODE
        end

        def setter_def finfo
          name = finfo.name
          "def #{name}= value; @struct[#{name.to_sym.inspect}] = value; end"
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
