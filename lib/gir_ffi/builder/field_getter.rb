require 'gir_ffi/builder/argument'
require 'gir_ffi/variable_name_generator'

module GirFFI
  module Builder
    # Creates field getter code for a given IFieldInfo.
    class FieldGetter
      def initialize field_info
        @info = field_info
      end

      def getter_def
        builder = return_value_builder

        return <<-CODE
        def #{@info.name}
          #{builder.cvar} = @struct[#{field_symbol.inspect}]
          #{builder.post.join("\n")}
          #{builder.retval}
        end
        CODE
      end

      private

      def field_symbol
        @info.name.to_sym
      end

      def return_value_builder
        @rv_builder ||= ReturnValueFactory.builder_for_field_getter(
          VariableNameGenerator.new, @info.name, @info.field_type)
      end
    end
  end
end
