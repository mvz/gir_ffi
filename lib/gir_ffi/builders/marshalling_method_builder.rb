require 'gir_ffi/builders/closure_argument_builder'
require 'gir_ffi/builders/callback_return_value_builder'
require 'gir_ffi/builders/argument_builder_collection'

module GirFFI
  module Builders
    class Template
      def initialize(builder, argument_builder_collection)
        @builder = builder
        @argument_builder_collection = argument_builder_collection
      end

      def method_definition
        code = "def self.#{@builder.method_name}(#{@builder.method_arguments.join(', ')})"
        method_lines.each { |line| code << "\n  #{line}" }
        code << "\nend\n"
      end

      private

      def method_lines
        method_preparation +
          parameter_preparation +
          invocation +
          return_value_conversion +
          result
      end

      def method_preparation
        @builder.preparation
      end

      def parameter_preparation
        @argument_builder_collection.parameter_preparation
      end

      def invocation
        if result_name_list.empty?
          plain_invocation
        else
          capturing_invocation
        end
      end

      def return_value_conversion
        @argument_builder_collection.return_value_conversion
      end

      def result
        @builder.result
      end

      def result_name_list
        @result_name_list ||=
          @argument_builder_collection.capture_variable_names.join(", ")
      end

      def capturing_invocation
        ["#{result_name_list} = #{@builder.invocation}"]
      end

      def plain_invocation
        [@builder.invocation]
      end
    end

    # Implements the creation mapping method for a callback or signal
    # handler. This method converts arguments from C to Ruby, and the
    # result from Ruby to C.
    class MarshallingMethodBuilder
      def self.for_signal receiver_info, argument_infos, return_value_info
        vargen = VariableNameGenerator.new

        receiver_builder = ClosureArgumentBuilder.new vargen, receiver_info
        argument_builders = argument_infos.
          map { |arg| ClosureArgumentBuilder.new vargen, arg }
        return_value_builder = CallbackReturnValueBuilder.new(vargen, return_value_info)

        new ArgumentBuilderCollection.new(return_value_builder, argument_builders,
                                          receiver_builder: receiver_builder)
      end

      def initialize argument_builder_collection
        @argument_builder_collection = argument_builder_collection
        @template = Template.new(self, @argument_builder_collection)
      end

      def method_definition
        @template.method_definition
      end

      def method_name
        "marshaller"
      end

      def method_arguments
        %w(closure return_value param_values _invocation_hint _marshal_data)
      end

      def preparation
        ["#{param_names.join(", ")} = param_values.map(&:get_value_plain)"]
      end

      def invocation
        "wrap(closure.to_ptr).invoke_block(#{call_argument_list})"
      end

      def result
        if (name = @argument_builder_collection.return_value_name)
          ["return_value.set_value #{name}"]
        else
          []
        end
      end

      private

      def call_argument_list
        @argument_builder_collection.call_argument_names.join(', ')
      end

      def param_names
        # FIXME: Don't add _ if method_argument_names has more than one element
        @param_names ||=
          @argument_builder_collection.method_argument_names.dup.push('_')
      end
    end
  end
end
