module GirFFI
  module Builders
    # Class representing the argument and return value builders for a callback
    # mapping function or marshaller. Implements collecting the conversion code
    # and parameter and variable names for use by function builders.
    class ArgumentBuilderCollection
      attr_reader :return_value_builder

      def initialize return_value_builder, argument_builders, options = {}
        @receiver_builder = options[:receiver_builder]
        @base_argument_builders = argument_builders
        @return_value_builder = return_value_builder
        set_up_argument_relations
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

      def argument_builders
        @argument_builders ||= if @receiver_builder
                                 @base_argument_builders.dup.unshift @receiver_builder
                               else
                                 @base_argument_builders
                               end
      end

      private

      def set_up_argument_relations
        @base_argument_builders.each do |arg|
          if (idx = arg.arginfo.closure) >= 0
            @base_argument_builders[idx].is_closure = true
          end
        end
        all_builders.each do |bldr|
          if (idx = bldr.array_length_idx) >= 0
            other = @base_argument_builders[idx]

            bldr.length_arg = other
            other.array_arg = bldr
          end
        end
      end

      def all_builders
        @all_builders ||= [return_value_builder] + argument_builders
      end
    end
  end
end
