# frozen_string_literal: true
require 'gir_ffi/variable_name_generator'
require 'gir_ffi/builders/closure_argument_builder'
require 'gir_ffi/builders/closure_return_value_builder'
require 'gir_ffi/builders/argument_builder_collection'
require 'gir_ffi/builders/method_template'

module GirFFI
  module Builders
    # Implements the creation mapping method for a signal
    # handler. This method converts arguments from C to Ruby, and the
    # result from Ruby to C.
    class MarshallingMethodBuilder < BaseMethodBuilder
      def self.for_signal(receiver_info, info)
        new receiver_info, info
      end

      def initialize(receiver_info, info)
        super(info, ClosureReturnValueBuilder,
              argument_builder_class: ClosureArgumentBuilder)
        @receiver_builder = make_argument_builder receiver_info
      end

      def argument_builder_collection
        @argument_builder_collection ||=
          ArgumentBuilderCollection.new(return_value_builder, argument_builders,
                                        receiver_builder: @receiver_builder)
      end

      ## Methods used by MethodTemplate

      def method_name
        'marshaller'
      end

      def method_arguments
        %w(closure return_value param_values _invocation_hint _marshal_data)
      end

      def preparation
        if param_names.size == 1
          ["#{param_names.first} = param_values.first.get_value_plain"]
        else
          ["#{param_names.join(', ')} = param_values.map(&:get_value_plain)"]
        end
      end

      def invocation
        "wrap(closure.to_ptr).invoke_block(#{call_argument_list})"
      end

      def result
        if (name = @argument_builder_collection.return_value_name)
          ["return_value.set_value #{name}"]
        else
          []
        end
      end

      def singleton_method?
        true
      end

      private

      def call_argument_list
        @argument_builder_collection.call_argument_names.join(', ')
      end

      def param_names
        @param_names ||= @argument_builder_collection.method_argument_names
      end
    end
  end
end
