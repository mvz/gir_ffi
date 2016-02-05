# frozen_string_literal: true
require 'gir_ffi/builders/argument_builder_collection'
require 'gir_ffi/builders/method_template'
require 'gir_ffi/builders/null_return_value_builder'

module GirFFI
  module Builders
    # Implements the creation of a Ruby constructor definition out of a
    # GIR IFunctionInfo.
    class ConstructorBuilder
      def initialize(info)
        @info = info
        return_value_builder = NullReturnValueBuilder.new
        arg_builders = ArgumentBuilderCollection.new(return_value_builder, [])
        @template = MethodTemplate.new(self, arg_builders)
      end

      def method_definition
        @template.method_definition
      end

      def singleton_method?
        true
      end

      def method_name
        @info.safe_name
      end

      def method_arguments
        ['*args', '&block']
      end

      def preparation
        if @info.safe_name == 'new'
          ['obj = allocate']
        else
          [
            "raise NoMethodError unless self == #{@info.container.full_type_name}",
            'obj = allocate'
          ]
        end
      end

      def invocation
        "obj.__send__ #{initializer_name.to_sym.inspect}, #{method_arguments.join(', ')}"
      end

      def result
        ['obj']
      end

      private

      def initializer_name
        @info.safe_name.sub(/^new/, 'initialize')
      end
    end
  end
end
