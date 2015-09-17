require 'gir_ffi/builders/argument_builder_collection'
require 'gir_ffi/builders/method_template'
require 'gir_ffi/builders/null_return_value_builder'

module GirFFI
  module Builders
    # Implements the creation of a Ruby constructor definition out of a
    # GIR IFunctionInfo.
    class ConstructorBuilder
      def initialize info
        @info = info
        return_value_builder = NullReturnValueBuilder.new
        arg_builders = ArgumentBuilderCollection.new(return_value_builder, [])
        @template = MethodTemplate.new(self, arg_builders)
      end

      def generate
        @template.method_definition
      end

      def singleton_method?
        true
      end

      def method_name
        @info.safe_name
      end

      def initializer_method_name
        @info.safe_name.sub(/^new/, 'initialize')
      end

      def method_arguments
        ['*args']
      end

      def preparation
        ['obj = allocate']
      end

      def invocation
        "obj.__send__ #{initializer_method_name.to_sym.inspect}, #{method_arguments.join(', ')}"
      end

      def result
        ['obj']
      end
    end
  end
end
