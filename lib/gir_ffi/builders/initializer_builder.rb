require 'gir_ffi/builders/initializer_return_value_builder'
require 'gir_ffi/builders/base_method_builder'

module GirFFI
  module Builders
    # Implements the creation of a Ruby object initializer definition out of a
    # GIR IFunctionInfo.
    class InitializerBuilder < BaseMethodBuilder
      def initialize(info)
        @info = info
        @return_value_builder = InitializerReturnValueBuilder.new(vargen,
                                                                  return_value_info)
      end

      def singleton_method?
        false
      end

      def method_name
        @info.safe_name.sub(/^new/, 'initialize')
      end

      def method_arguments
        argument_builder_collection.method_argument_names
      end

      def preparation
        []
      end

      def result
        []
      end

      def function_call_arguments
        argument_builder_collection.call_argument_names
      end
    end
  end
end
