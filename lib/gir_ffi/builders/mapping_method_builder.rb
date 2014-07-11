require 'gir_ffi/builders/callback_argument_builder'
require 'gir_ffi/builders/callback_return_value_builder'
require 'gir_ffi/builders/argument_builder_collection'

module GirFFI
  module Builders
    # Implements the creation mapping method for a callback or signal
    # handler. This method converts arguments from C to Ruby, and the
    # result from Ruby to C.
    class MappingMethodBuilder
      def self.for_callback argument_infos, return_value_info
        vargen = VariableNameGenerator.new

        argument_builders = argument_infos.
          map { |arg| CallbackArgumentBuilder.new vargen, arg }
        return_value_builder = CallbackReturnValueBuilder.new(vargen, return_value_info)

        new ArgumentBuilderCollection.new(return_value_builder, argument_builders)
      end

      def self.for_vfunc receiver_info, argument_infos, return_value_info
        vargen = VariableNameGenerator.new

        receiver_builder = CallbackArgumentBuilder.new vargen, receiver_info
        argument_builders = argument_infos.
          map { |arg| CallbackArgumentBuilder.new vargen, arg }
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

      private

      def call_argument_list
        @argument_builder_collection.call_argument_names.join(', ')
      end
    end
  end
end
