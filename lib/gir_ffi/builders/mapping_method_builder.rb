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
    #
    class MappingMethodBuilder < BaseMethodBuilder
      def self.for_callback(info)
        new nil, info, CallbackArgumentBuilder
      end

      def self.for_vfunc(receiver_info, info)
        new receiver_info, info, VFuncArgumentBuilder
      end

      def initialize(receiver_info, info, builder_class)
        @info = info
        @argument_builder_class = builder_class
        @receiver_builder = receiver_info ? make_argument_builder(receiver_info) : nil
      end

      def return_value_builder
        @return_value_builder ||=
          CallbackReturnValueBuilder.new(variable_generator, return_value_info)
      end

      def argument_builders
        @argument_builders ||=
          begin
            argument_infos = @info.args
            argument_infos << ErrorArgumentInfo.new if @info.can_throw_gerror?
            argument_infos.map { |it| make_argument_builder it }
          end
      end

      def argument_builder_collection
        @argument_builder_collection ||=
          ArgumentBuilderCollection.new(return_value_builder, argument_builders,
                                        receiver_builder: @receiver_builder)
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

      def make_argument_builder(argument_info)
        @argument_builder_class.new variable_generator, argument_info
      end
    end
  end
end
