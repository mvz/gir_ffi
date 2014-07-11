require 'gir_ffi/builders/argument_builder'
require 'gir_ffi/return_value_info'
require 'gir_ffi/error_argument_info'
require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/builders/error_argument_builder'
require 'gir_ffi/variable_name_generator'

module GirFFI
  module Builders
    # Implements the creation of a Ruby function definition out of a GIR
    # IFunctionInfo.
    class FunctionBuilder
      def initialize info
        @info = info
        vargen = GirFFI::VariableNameGenerator.new
        @argument_builders = @info.args.map { |arg| ArgumentBuilder.new vargen, arg }
        @return_value_builder =
          ReturnValueBuilder.new(vargen,
                                 ReturnValueInfo.new(@info.return_type, @info.skip_return?),
                                 @info.constructor?)
        @argument_builder_collection =
          ArgumentBuilderCollection.new(@return_value_builder,
                                        @argument_builders,
                                        error_argument_builder: error_argument(vargen))
      end

      def generate
        code = "def #{qualified_method_name}"
        code << " #{method_arguments.join(', ')}" if method_arguments.any?
        method_lines.each { |line| code << "\n  #{line}" }
        code << "\nend\n"
      end

      private

      def qualified_method_name
        "#{@info.method? ? '' : "self."}#{@info.safe_name}"
      end

      def lib_name
        "#{@info.safe_namespace}::Lib"
      end

      def error_argument vargen
        if @info.throws?
          ErrorArgumentBuilder.new vargen, ErrorArgumentInfo.new if @info.throws?
        end
      end

      def method_lines
        preparation +
        @argument_builder_collection.parameter_preparation +
          invocation +
          @argument_builder_collection.return_value_conversion +
          result
      end

      def preparation
        []
      end

      def result
        if @argument_builder_collection.has_return_values?
          ["return #{@argument_builder_collection.return_value_names.join(', ')}"]
        else
          []
        end
      end

      def invocation
        ["#{capture}#{lib_name}.#{@info.symbol} #{function_call_arguments.join(', ')}"]
      end

      def method_arguments
        @argument_builder_collection.method_argument_names
      end

      def function_call_arguments
        ca = @argument_builder_collection.call_argument_names
        ca.unshift "self" if @info.method?
        ca
      end

      def capture
        @capture ||= begin
                       names = @argument_builder_collection.capture_variable_names
                       names.any? ? "#{names.join(", ")} = " : ""
                     end
      end
    end
  end
end
