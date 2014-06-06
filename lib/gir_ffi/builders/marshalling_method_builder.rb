require 'gir_ffi/builders/closure_argument_builder'
require 'gir_ffi/builders/callback_return_value_builder'
require 'gir_ffi/builders/mapping_method_builder'

module GirFFI
  module Builders
    # Implements the creation mapping method for a callback or signal
    # handler. This method converts arguments from C to Ruby, and the
    # result from Ruby to C.
    class MarshallingMethodBuilder
      def self.for_signal receiver_info, argument_infos, return_type_info
        vargen = VariableNameGenerator.new

        receiver_builder = ClosureArgumentBuilder.new vargen, receiver_info
        argument_builders = argument_infos.map {|arg|
          ClosureArgumentBuilder.new vargen, arg }

        Foo.set_up_argument_relations argument_infos, argument_builders

        argument_builders.unshift receiver_builder
        foo = Foo.new return_type_info, vargen, argument_builders

        new return_type_info, vargen, argument_builders, foo
      end

      def initialize return_type_info, vargen, argument_builders, foo
        @vargen = vargen
        @argument_builders = argument_builders
        @return_type_info = return_type_info
        @foo = foo
      end

      attr_reader :return_type_info
      attr_reader :vargen
      attr_reader :argument_builders

      def method_definition
        code = "def self.marshaller(#{marshaller_arguments.join(', ')})"
        method_lines.each { |line| code << "\n  #{line}" }
        code << "\nend\n"
      end

      def method_lines
        param_values_unpack +
          parameter_preparation +
          call_to_closure +
          return_value_conversion +
          return_value
      end

      def return_value
        if return_value_builder.is_relevant?
          ["return_value.set_value #{return_value_builder.return_value_name}"]
        else
          []
        end
      end

      def return_value_conversion
        all_builders.map(&:post_conversion).flatten
      end

      def call_to_closure
        ["#{capture}wrap(closure.to_ptr).invoke_block(#{call_arguments.join(', ')})"]
      end

      def param_values_unpack
        # FIXME: Don't add _ if method_arguments has more than one element
        ["#{method_arguments.join(", ")}, _ = param_values.map(&:get_value_plain)" ]
      end

      def parameter_preparation
        argument_builders.sort_by.with_index {|arg, i|
          [arg.type_info.array_length, i] }.map(&:pre_conversion).flatten
      end

      def capture
        @capture ||= capture_variable_names.any? ?
          "#{capture_variable_names.join(", ")} = " :
          ""
      end

      def capture_variable_names
        @capture_variable_names ||=
          all_builders.map(&:capture_variable_name).compact
      end

      def all_builders
        @all_builders ||= [return_value_builder] + argument_builders
      end

      def call_arguments
        @call_arguments ||= argument_builders.map(&:call_argument_name).compact
      end

      def method_arguments
        @method_arguments ||= argument_builders.map(&:method_argument_name)
      end

      def marshaller_arguments
        %w(closure return_value param_values _invocation_hint _marshal_data)
      end

      def return_value_info
        @return_value_info ||= ReturnValueInfo.new(return_type_info)
      end

      def return_value_builder
        @return_value_builder ||= CallbackReturnValueBuilder.new(vargen, return_value_info)
      end
    end
  end
end


