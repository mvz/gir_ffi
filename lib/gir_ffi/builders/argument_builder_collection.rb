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
          all_builders.filter_map(&:capture_variable_name)
      end

      def call_argument_names
        @call_argument_names ||= argument_builders.filter_map(&:call_argument_name)
      end

      def method_argument_names
        @method_argument_names ||=
          begin
            base, block = split_off_block_argument
            args = base_argument_names(base)
            args << "&#{block.method_argument_name}" if block
            args
          end
      end

      def return_value_name
        return_value_builder.return_value_name
      end

      def return_value_names
        @return_value_names ||= all_builders.filter_map(&:return_value_name)
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
        set_up_user_data_relations
        set_up_destroy_notifier_relations
        set_up_length_argument_relations
      end

      def set_up_user_data_relations
        @base_argument_builders.each do |bldr|
          if (idx = bldr.closure_idx) >= 0
            target_bldr = @base_argument_builders[idx]
            unless target_bldr.specialized_type_tag == :void
              target_bldr, bldr = bldr, target_bldr
            end
            target_bldr.mark_as_user_data bldr
          end
        end
      end

      def set_up_destroy_notifier_relations
        @base_argument_builders.each do |bldr|
          if (idx = bldr.destroy_idx) >= 0
            target = @base_argument_builders[idx]
            if target.specialized_type_tag == :callback &&
               bldr.specialized_type_tag == :callback
              target.mark_as_destroy_notifier bldr
            else
              warn "Not marking #{target.name} (#{target.specialized_type_tag})" \
                   " as destroy notifier for #{bldr.name} (#{bldr.specialized_type_tag})"
            end
          end
        end
      end

      def set_up_length_argument_relations
        all_builders.each do |bldr|
          idx = bldr.array_length_idx
          next if idx < 0

          other = @base_argument_builders[idx]
          bldr.length_arg = other
          other.array_arg = bldr
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
        @sorted_base_argument_builders ||= @base_argument_builders
          .sort_by.with_index { |arg, i| [arg.array_length_idx, i] }
      end

      def split_off_block_argument
        builders_with_name = argument_builders.select(&:method_argument_name)
        blocks, base = builders_with_name.partition(&:block_argument?)
        case blocks.count
        when 1
          return base, blocks.first
        else
          return builders_with_name, nil
        end
      end

      def base_argument_names(arguments)
        required_found = false
        arguments.reverse.filter_map do |it|
          name = it.method_argument_name
          if it.allow_none? && !required_found
            "#{name} = nil"
          else
            required_found = true
            name
          end
        end.reverse
      end
    end
  end
end
