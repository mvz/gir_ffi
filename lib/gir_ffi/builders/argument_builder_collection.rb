# frozen_string_literal: true
module GirFFI
  module Builders
    # Class representing the argument and return value builders for a method,
    # callback mapping function or marshaller. Implements collecting the
    # conversion code and parameter and variable names for use by function
    # builders.
    class ArgumentBuilderCollection
      attr_reader :return_value_builder

      def initialize(return_value_builder, argument_builders,
                     receiver_builder: nil, error_argument_builder: nil)
        @receiver_builder = receiver_builder
        @error_argument_builder = error_argument_builder
        @base_argument_builders = argument_builders
        @return_value_builder = return_value_builder
        set_up_argument_relations
      end

      def parameter_preparation
        builders_for_pre_conversion.map(&:pre_conversion).flatten
      end

      def return_value_conversion
        builders_for_post_conversion.map(&:post_conversion).flatten
      end

      def capture_variable_names
        @capture_variable_names ||=
          all_builders.map(&:capture_variable_name).compact
      end

      def call_argument_names
        @call_argument_names ||= argument_builders.map(&:call_argument_name).compact
      end

      def method_argument_names
        @method_argument_names ||=
          begin
            base = []
            block = nil
            argument_builders.each do |it|
              if !block && it.block_argument?
                block = it
              else
                base << it
              end
            end
            required_found = false
            args = base.reverse.map do |it|
              name = it.method_argument_name
              next unless name
              if it.allow_none? && !required_found
                "#{name} = nil"
              else
                required_found = true
                name
              end
            end.compact.reverse
            args << "&#{block.method_argument_name}" if block
            args
          end
      end

      def return_value_name
        return_value_builder.return_value_name
      end

      def return_value_names
        @return_value_names ||= all_builders.map(&:return_value_name).compact
      end

      def has_return_values?
        return_value_names.any?
      end

      private

      def argument_builders
        @argument_builders ||= @base_argument_builders.dup.tap do |builders|
          builders.unshift @receiver_builder if @receiver_builder
          builders.push @error_argument_builder if @error_argument_builder
        end
      end

      def set_up_argument_relations
        @base_argument_builders.each do |bldr|
          if (idx = bldr.closure_idx) >= 0
            @base_argument_builders[idx].closure = bldr
          end
          if (idx = bldr.destroy_idx) >= 0
            @base_argument_builders[idx].mark_as_destroy_notifier bldr
          end
        end
        all_builders.each do |bldr|
          if (idx = bldr.array_length_idx) >= 0
            other = @base_argument_builders[idx]
            next unless other

            bldr.length_arg = other
            other.array_arg = bldr
          end
        end
      end

      def all_builders
        @all_builders ||= [return_value_builder] + argument_builders
      end

      def builders_for_pre_conversion
        @builders_for_pre_conversion ||=
          sorted_base_argument_builders.dup.tap do |builders|
            builders.unshift @receiver_builder if @receiver_builder
            builders.push @error_argument_builder if @error_argument_builder
          end
      end

      def builders_for_post_conversion
        @builders_for_post_conversion ||=
          sorted_base_argument_builders.dup.tap do |builders|
            builders.unshift @receiver_builder if @receiver_builder
            builders.unshift @error_argument_builder if @error_argument_builder
            builders.push return_value_builder
          end
      end

      def sorted_base_argument_builders
        @sorted_base_argument_builders ||= @base_argument_builders.
          sort_by.with_index { |arg, i| [arg.array_length_idx, i] }
      end
    end
  end
end
