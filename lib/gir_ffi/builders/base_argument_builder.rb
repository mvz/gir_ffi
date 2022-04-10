# frozen_string_literal: true

module GirFFI
  module Builders
    # Abstract parent class of the argument building classes. These
    # classes are used by FunctionBuilder to create the code that
    # processes each argument before and after the actual function call.
    class BaseArgumentBuilder
      KEYWORDS = %w[
        alias and begin break case class def do
        else elsif end ensure false for if in
        module next nil not or redo rescue retry
        return self super then true undef unless
        until when while yield
      ].freeze

      attr_reader :arginfo, :related_callback_builder

      attr_accessor :length_arg, :array_arg

      def initialize(var_gen, arginfo)
        @var_gen = var_gen
        @arginfo = arginfo
        @length_arg = nil
        @array_arg = nil
        @is_user_data = false
        @is_destroy_notifier = false
      end

      def name
        @name ||= safe(arginfo.name)
      end

      def direction
        @direction ||= arginfo.direction
      end

      def type_info
        @type_info ||= arginfo.argument_type
      end

      def specialized_type_tag
        type_info.flattened_tag
      end

      # TODO: Use class rather than class name
      def argument_class_name
        type_info.argument_class_name
      end

      def array_length_idx
        type_info.array_length
      end

      def closure_idx
        arginfo.closure
      end

      def destroy_idx
        arginfo.destroy
      end

      def mark_as_user_data(callback_builder)
        @is_user_data = true
        @related_callback_builder = callback_builder
      end

      def mark_as_destroy_notifier(callback_builder)
        @is_destroy_notifier = true
        @related_callback_builder = callback_builder
      end

      def array_length_parameter?
        @array_arg
      end

      def user_data?
        @is_user_data
      end

      def destroy_notifier?
        @is_destroy_notifier
      end

      def helper_argument?
        array_length_parameter? || user_data? || destroy_notifier?
      end

      def ownership_transfer
        arginfo.ownership_transfer
      end

      def safe(name)
        if KEYWORDS.include? name
          "#{name}_"
        else
          name
        end
      end

      def call_argument_name
        @call_argument_name ||= new_variable
      end

      def new_variable
        @var_gen.new_var
      end
    end
  end
end
