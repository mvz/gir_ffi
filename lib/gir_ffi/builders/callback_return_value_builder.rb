# frozen_string_literal: true
require 'gir_ffi/builders/base_return_value_builder'
require 'gir_ffi/builders/ruby_to_c_convertor'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values of
    # callbacks.
    class CallbackReturnValueBuilder < BaseReturnValueBuilder
      def post_converted_name
        @post_converted_name ||= if has_post_conversion?
                                   new_variable
                                 else
                                   capture_variable_name
                                 end
      end

      def return_value_name
        post_converted_name if has_return_value_name?
      end

      def post_conversion
        if has_post_conversion?
          if type_info.flattened_tag == :object
            ["#{post_converted_name} = #{post_convertor.conversion}.to_ptr"]
          else
            ["#{post_converted_name} = #{post_convertor.conversion}"]
          end
        else
          []
        end
      end

      def has_post_conversion?
        relevant? && needs_ruby_to_c_conversion?
      end

      def needs_ruby_to_c_conversion?
        type_info.needs_ruby_to_c_conversion_for_callbacks?
      end

      private

      def post_convertor
        @post_convertor ||= RubyToCConvertor.new(type_info, post_convertor_argument)
      end

      def post_convertor_argument
        if ownership_transfer == :everything && specialized_type_tag == :object
          "#{capture_variable_name}.ref"
        else
          capture_variable_name
        end
      end

      def has_return_value_name?
        relevant? && !array_arg
      end
    end
  end
end
