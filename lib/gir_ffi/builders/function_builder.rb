require 'gir_ffi/error_argument_info'
require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/builders/error_argument_builder'
require 'gir_ffi/builders/method_template'
require 'gir_ffi/builders/base_method_builder'

module GirFFI
  module Builders
    # Implements the creation of a Ruby function definition out of a GIR
    # IFunctionInfo.
    class FunctionBuilder < BaseMethodBuilder
      def initialize(info)
        @info = info
        @return_value_builder = ReturnValueBuilder.new(vargen,
                                                       return_value_info)
        @argument_builder_collection = ArgumentBuilderCollection.new(
          @return_value_builder, argument_builders,
          error_argument_builder: error_argument(vargen))
        @template = MethodTemplate.new(self, @argument_builder_collection)
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

      def error_argument(vargen)
        if @info.throws?
          ErrorArgumentBuilder.new vargen, ErrorArgumentInfo.new
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
