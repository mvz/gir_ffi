require 'gir_ffi/variable_name_generator'
require 'gir_ffi/builders/argument_builder'
require 'gir_ffi/return_value_info'
require 'gir_ffi/builders/method_template'

module GirFFI
  module Builders
    # Base class for method definition builders.
    class BaseMethodBuilder
      def vargen
        @vargen ||= VariableNameGenerator.new
      end

      def argument_builders
        @argument_builders ||= @info.args.map { |arg| ArgumentBuilder.new vargen, arg }
      end

      def return_value_info
        @return_value_info ||= ReturnValueInfo.new(@info.return_type,
                                                   @info.caller_owns,
                                                   @info.skip_return?)
      end

      def method_definition
        template.method_definition
      end

      def template
        @template ||= MethodTemplate.new(self, @argument_builder_collection)
      end
    end
  end
end
