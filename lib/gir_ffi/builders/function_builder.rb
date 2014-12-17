require 'gir_ffi/variable_name_generator'
require 'gir_ffi/builders/argument_builder'
require 'gir_ffi/return_value_info'
require 'gir_ffi/error_argument_info'
require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/builders/error_argument_builder'
require 'gir_ffi/builders/method_template'

module GirFFI
  module Builders
    # Implements the creation of a Ruby function definition out of a GIR
    # IFunctionInfo.
    class FunctionBuilder
      def initialize info
        @info = info
        vargen = GirFFI::VariableNameGenerator.new
        @argument_builders = @info.args.map { |arg| ArgumentBuilder.new vargen, arg }
        return_value_info = ReturnValueInfo.new(@info.return_type,
                                                @info.caller_owns,
                                                @info.skip_return?)
        @return_value_builder = ReturnValueBuilder.new(vargen,
                                                       return_value_info,
                                                       @info.constructor?)
        @argument_builder_collection = ArgumentBuilderCollection.new(
          @return_value_builder, @argument_builders,
          error_argument_builder: error_argument(vargen))
        @template = MethodTemplate.new(self, @argument_builder_collection)
      end

      def generate
        @template.method_definition
      end

      def method_name
        @info.safe_name
      end

      def method_arguments
        @argument_builder_collection.method_argument_names
      end

      def preparation
        []
      end

      def invocation
        "#{lib_name}.#{@info.symbol} #{function_call_arguments.join(', ')}"
      end

      def result
        if @argument_builder_collection.has_return_values?
          ["return #{@argument_builder_collection.return_value_names.join(', ')}"]
        else
          []
        end
      end

      def singleton_method?
        !@info.method?
      end

      private

      def lib_name
        "#{@info.safe_namespace}::Lib"
      end

      def error_argument vargen
        if @info.throws?
          ErrorArgumentBuilder.new vargen, ErrorArgumentInfo.new if @info.throws?
        end
      end

      def function_call_arguments
        ca = @argument_builder_collection.call_argument_names
        ca.unshift receiver_call_argument if @info.method?
        ca
      end

      def receiver_call_argument
        if @info.instance_ownership_transfer == :everything
          'self.ref'
        else
          'self'
        end
      end
    end
  end
end
