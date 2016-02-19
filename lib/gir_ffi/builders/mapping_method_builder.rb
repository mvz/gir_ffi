# frozen_string_literal: true
require 'gir_ffi/variable_name_generator'
require 'gir_ffi/builders/callback_argument_builder'
require 'gir_ffi/builders/vfunc_argument_builder'
require 'gir_ffi/builders/callback_return_value_builder'
require 'gir_ffi/builders/argument_builder_collection'
require 'gir_ffi/builders/base_method_builder'

module GirFFI
  module Builders
    # Implements the creation mapping method for a callback or vfunc
    # handler. This method converts arguments from C to Ruby, and the
    # result from Ruby to C.
    class MappingMethodBuilder < BaseMethodBuilder
      def self.for_callback(info)
        new nil, info, CallbackArgumentBuilder
      end

      def self.for_vfunc(receiver_info, info)
        new receiver_info, info, VFuncArgumentBuilder
      end

      def initialize(receiver_info, info, builder_class)
        super(info, CallbackReturnValueBuilder,
              receiver_info: receiver_info,
              argument_builder_class: builder_class)
      end

      ## Methods used by MethodTemplate

      def method_name
        'call_with_argument_mapping'
      end

      def method_arguments
        @method_arguments ||=
          argument_builder_collection.method_argument_names.dup.unshift('_proc')
      end

      def invocation
        "_proc.call(#{call_argument_list})"
      end

      def result
        if (name = argument_builder_collection.return_value_name)
          ["return #{name}"]
        else
          []
        end
      end

      def singleton_method?
        true
      end

      private

      def call_argument_list
        argument_builder_collection.call_argument_names.join(', ')
      end
    end
  end
end
