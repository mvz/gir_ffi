require 'gir_ffi/variable_name_generator'
require 'gir_ffi/builders/closure_argument_builder'
require 'gir_ffi/builders/callback_return_value_builder'
require 'gir_ffi/builders/argument_builder_collection'
require 'gir_ffi/builders/method_template'

module GirFFI
  module Builders
    # Implements the creation mapping method for a callback or signal
    # handler. This method converts arguments from C to Ruby, and the
    # result from Ruby to C.
    class MarshallingMethodBuilder
      def self.for_signal receiver_info, argument_infos, return_value_info
        new receiver_info, argument_infos, return_value_info
      end

      def initialize receiver_info, argument_infos, return_value_info
        receiver_builder = make_argument_builder receiver_info
        argument_builders = argument_infos.map { |arg| make_argument_builder arg }
        return_value_builder =
          CallbackReturnValueBuilder.new(variable_generator, return_value_info)

        @argument_builder_collection =
          ArgumentBuilderCollection.new(return_value_builder, argument_builders,
                                        receiver_builder: receiver_builder)
        @template = MethodTemplate.new(self, @argument_builder_collection)
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

      def singleton_method?
        true
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

      def variable_generator
        @variable_generator ||= VariableNameGenerator.new
      end

      def make_argument_builder argument_info
        ClosureArgumentBuilder.new variable_generator, argument_info
      end
    end
  end
end
