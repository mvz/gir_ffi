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

        argument_builders = argument_infos.map {|arg| CallbackArgumentBuilder.new vargen, arg }
        return_value_builder = CallbackReturnValueBuilder.new(vargen, return_value_info)

        new ArgumentBuilderCollection.new(return_value_builder, argument_builders)
      end

      def self.for_vfunc receiver_info, argument_infos, return_value_info
        vargen = VariableNameGenerator.new

        receiver_builder = CallbackArgumentBuilder.new vargen, receiver_info
        argument_builders = argument_infos.map {|arg| CallbackArgumentBuilder.new vargen, arg }
        return_value_builder = CallbackReturnValueBuilder.new(vargen, return_value_info)

        new ArgumentBuilderCollection.new(return_value_builder, argument_builders,
                                          receiver_builder: receiver_builder)
      end

      def initialize argument_builder_collection
        @argument_builder_collection = argument_builder_collection
      end

      def method_definition
        code = "def self.call_with_argument_mapping(#{method_arguments.join(', ')})"
        method_lines.each { |line| code << "\n  #{line}" }
        code << "\nend\n"
      end

      private

      def method_lines
        @argument_builder_collection.parameter_preparation +
          call_to_proc +
          @argument_builder_collection.return_value_conversion +
          return_value
      end

      def return_value
        if (name = @argument_builder_collection.return_value_name)
          ["return #{name}"]
        else
          []
        end
      end

      def call_to_proc
        ["#{capture}_proc.call(#{@argument_builder_collection.call_argument_names.join(', ')})"]
      end

      def capture
        @capture ||= begin
                       names = @argument_builder_collection.capture_variable_names
                       names.any? ? "#{names.join(", ")} = " : ""
                     end
      end

      def method_arguments
        @method_arguments ||= @argument_builder_collection.method_argument_names.dup.unshift('_proc')
      end
    end
  end
end
