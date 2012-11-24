require 'gir_ffi/builder/argument'
require 'gir_ffi/variable_name_generator'

module GirFFI
  module Builder
    # Creates field getter and setter code for a given IFieldInfo.
    class Field
      def initialize field_info, lib_module, struct_class
        @info = field_info
        @libmodule = lib_module
        @struct_class = struct_class
      end

      def getter_def
        builder = return_value_builder

        return <<-CODE
        def #{@info.name}
          struct = #{@struct_class}.new @struct.to_ptr
          #{builder.cvar} = struct[#{field_symbol.inspect}]
          #{builder.post.join("\n")}
          #{builder.retval}
        end
        CODE
      end

      def setter_def
        builder = setter_builder
        name = @info.name

        return <<-CODE
        def #{name}= #{builder.inarg}
          #{builder.pre.join("\n")}
          struct = #{@struct_class}.new @struct.to_ptr
          struct[#{name.to_sym.inspect}] = #{builder.callarg}
        end
        CODE
      end

      private

      def field_symbol
        @info.name.to_sym
      end

      def return_value_builder
        @rv_builder ||= ReturnValueFactory.builder_for_field_getter(
          VariableNameGenerator.new, @info.name, @info.field_type, :return)
      end

      def setter_builder
        type = @info.field_type
        vargen = VariableNameGenerator.new
        Builder::InArgument.builder_for vargen, "value", type, :in
      end
    end
  end
end
