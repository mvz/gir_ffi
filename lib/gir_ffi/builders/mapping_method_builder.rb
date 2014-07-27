require 'gir_ffi/variable_name_generator'
require 'gir_ffi/builders/callback_argument_builder'
require 'gir_ffi/builders/callback_return_value_builder'
require 'gir_ffi/builders/argument_builder_collection'
require 'gir_ffi/builders/method_template'

module GirFFI
  module Builders
    # Implements the creation mapping method for a callback or signal
    # handler. This method converts arguments from C to Ruby, and the
    # result from Ruby to C.
    class MappingMethodBuilder
      def self.for_callback argument_infos, return_value_info
        new argument_infos, return_value_info
      end

      def self.for_vfunc receiver_info, argument_infos, return_value_info
        new receiver_info, argument_infos, return_value_info
      end

      def initialize receiver_info = nil, argument_infos, return_value_info
        receiver_builder = make_argument_builder receiver_info if receiver_info
        argument_builders = argument_infos.map { |info| make_argument_builder info }
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
        "call_with_argument_mapping"
      end

      def method_arguments
        @method_arguments ||=
          @argument_builder_collection.method_argument_names.dup.unshift('_proc')
      end

      def preparation
        []
      end

      def invocation
        "_proc.call(#{call_argument_list})"
      end

      def result
        if (name = @argument_builder_collection.return_value_name)
          ["return #{name}"]
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

      def variable_generator
        @variable_generator ||= VariableNameGenerator.new
      end

      def make_argument_builder argument_info
        CallbackArgumentBuilder.new variable_generator, argument_info
      end
    end
  end
end
