# frozen_string_literal: true

require "gir_ffi/builders/return_value_builder"
require "gir_ffi/builders/base_method_builder"

module GirFFI
  module Builders
    # Implements the creation of a Ruby function definition out of a GIR
    # IFunctionInfo.
    class FunctionBuilder < BaseMethodBuilder
      def initialize(info)
        super(info, ReturnValueBuilder)
      end

      def method_name
        @info.safe_name
      end

      def result
        if argument_builder_collection.has_return_values?
          ["return #{argument_builder_collection.return_value_names.join(', ')}"]
        else
          []
        end
      end

      def singleton_method?
        !@info.method?
      end

      def function_call_arguments
        ca = argument_builder_collection.call_argument_names.dup
        ca.unshift receiver_call_argument if @info.method?
        ca
      end

      private

      def receiver_call_argument
        container_type_info = ReceiverTypeInfo.new(container_info)
        if @info.instance_ownership_transfer == :everything && container_type_info.flattened_tag == :object
          "self.ref"
        else
          "self"
        end
      end

      def container_info
        @container_info ||= @info.container
      end
    end
  end
end
