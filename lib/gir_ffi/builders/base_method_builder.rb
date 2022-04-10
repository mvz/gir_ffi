# frozen_string_literal: true

require "gir_ffi/builders/argument_builder"
require "gir_ffi/builders/argument_builder_collection"
require "gir_ffi/builders/method_template"
require "gir_ffi/builders/null_argument_builder"
require "gir_ffi/error_argument_info"
require "gir_ffi/return_value_info"
require "gir_ffi/variable_name_generator"

module GirFFI
  module Builders
    # Base class for method definition builders.
    class BaseMethodBuilder
      def initialize(info, return_value_builder_class,
                     receiver_info: nil,
                     argument_builder_class: ArgumentBuilder)
        @info = info
        @return_value_builder_class = return_value_builder_class
        @argument_builder_class = argument_builder_class
        @receiver_info = receiver_info
      end

      def variable_generator
        @variable_generator ||= VariableNameGenerator.new
      end

      def method_definition
        template.method_definition
      end

      def template
        @template ||= MethodTemplate.new(self, argument_builder_collection)
      end

      # Methods used for setting up the builders

      def argument_builders
        @argument_builders ||=
          @info.args.map { |arg| make_argument_builder arg }
      end

      def return_value_info
        @return_value_info ||= ReturnValueInfo.new(@info.return_type,
                                                   @info.caller_owns,
                                                   @info.skip_return?)
      end

      def return_value_builder
        @return_value_builder = @return_value_builder_class.new(variable_generator,
                                                                return_value_info)
      end

      def receiver_builder
        @receiver_builder ||= @receiver_info ? make_argument_builder(@receiver_info) : nil
      end

      def argument_builder_collection
        @argument_builder_collection ||=
          ArgumentBuilderCollection.new(return_value_builder, argument_builders,
                                        error_argument_builder: error_argument,
                                        receiver_builder: receiver_builder)
      end

      def error_argument
        @error_argument ||=
          if @info.can_throw_gerror?
            make_argument_builder ErrorArgumentInfo.new
          else
            NullArgumentBuilder.new
          end
      end

      # Methods used by MethodTemplate

      def invocation
        "#{lib_name}.#{@info.symbol} #{function_call_arguments.join(', ')}".strip
      end

      def method_arguments
        argument_builder_collection.method_argument_names
      end

      def preparation
        []
      end

      private

      def lib_name
        "#{@info.safe_namespace}::Lib"
      end

      def make_argument_builder(argument_info)
        @argument_builder_class.new variable_generator, argument_info
      end
    end
  end
end
