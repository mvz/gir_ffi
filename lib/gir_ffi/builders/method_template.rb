# frozen_string_literal: true

module GirFFI
  module Builders
    # Encapsulates the general structure of generated methods, consisting of a
    # preparation phase where arguments are converted to the form needed by the
    # main call of the method, the main call itself, a post-processing phase
    # where the return values and any 'out' arguments of the main call are
    # converted into a form suitable for returning, and finally the returning
    # of said values to the caller.
    #
    # The different method builders collaborate with MethodTemplate to build
    # the desired method.
    class MethodTemplate
      def initialize(builder, argument_builder_collection)
        @builder = builder
        @argument_builder_collection = argument_builder_collection
      end

      def method_definition
        code = "def #{qualified_method_name}"
        code << "(#{method_arguments.join(", ")})" if method_arguments.any?
        method_lines.each { |line| code << "\n  #{line}" }
        code << "\nend\n"
      end

      private

      def qualified_method_name
        "#{@builder.singleton_method? ? "self." : ""}#{@builder.method_name}"
      end

      def method_arguments
        @builder.method_arguments
      end

      def method_lines
        method_preparation +
          parameter_preparation +
          invocation +
          return_value_conversion +
          result
      end

      def method_preparation
        @builder.preparation
      end

      def parameter_preparation
        @argument_builder_collection.parameter_preparation
      end

      def invocation
        if result_name_list.empty?
          plain_invocation
        else
          capturing_invocation
        end
      end

      def return_value_conversion
        @argument_builder_collection.return_value_conversion
      end

      def result
        @builder.result
      end

      def result_name_list
        @result_name_list ||=
          @argument_builder_collection.capture_variable_names.join(", ")
      end

      def capturing_invocation
        ["#{result_name_list} = #{@builder.invocation}"]
      end

      def plain_invocation
        [@builder.invocation].compact
      end
    end
  end
end
