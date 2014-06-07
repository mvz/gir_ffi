module GirFFI
  module Builders
    # Class representing the argument and return value builders for a callback
    # mapping function or marshaller. Implements collecting the conversion code
    # and parameter and variable names for use by function builders.
    class ArgumentBuilderCollection
      attr_reader :return_value_builder
      attr_reader :argument_builders

      def initialize return_value_builder, argument_builders, options = {}
        @receiver_builder = options[:receiver_builder]
        @argument_builders = argument_builders
        @return_value_builder = return_value_builder
        self.class.set_up_argument_relations argument_builders
        @argument_builders.unshift @receiver_builder if @receiver_builder
      end

      def parameter_preparation
        argument_builders.sort_by.with_index {|arg, i|
          [arg.type_info.array_length, i] }.map(&:pre_conversion).flatten
      end

      def return_value_conversion
        all_builders.map(&:post_conversion).flatten
      end

      def capture_variable_names
        @capture_variable_names ||=
          all_builders.map(&:capture_variable_name).compact
      end

      def call_argument_names
        @call_argument_names ||= argument_builders.map(&:call_argument_name).compact
      end

      def method_argument_names
        @method_argument_names ||= argument_builders.map(&:method_argument_name)
      end

      def return_value_name
        return_value_builder.return_value_name if return_value_builder.is_relevant?
      end

      def self.set_up_argument_relations argument_builders
        argument_builders.each do |arg|
          if (idx = arg.arginfo.closure) >= 0
            argument_builders[idx].is_closure = true
          end
        end
        argument_builders.each do |bldr|
          if (idx = bldr.array_length_idx) >= 0
            other = argument_builders[idx]

            bldr.length_arg = other
            other.array_arg = bldr
          end
        end
      end

      private

      def all_builders
        @all_builders ||= [return_value_builder] + argument_builders
      end
    end
  end
end
