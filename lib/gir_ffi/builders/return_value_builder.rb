# frozen_string_literal: true
require 'gir_ffi/builders/base_return_value_builder'
require 'gir_ffi/builders/full_c_to_ruby_convertor'
require 'gir_ffi/builders/closure_convertor'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values.
    class ReturnValueBuilder < BaseReturnValueBuilder
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
          ["#{post_converted_name} = #{post_convertor.conversion}"]
        else
          []
        end
      end

      private

      def has_post_conversion?
        closure? || type_info.needs_c_to_ruby_conversion_for_functions?
      end

      def post_convertor
        @post_convertor ||= if closure?
                              ClosureConvertor.new(capture_variable_name)
                            else
                              FullCToRubyConvertor.new(type_info,
                                                       capture_variable_name,
                                                       length_argument_name)
                            end
      end

      def length_argument_name
        length_arg && length_arg.post_converted_name
      end

      def has_return_value_name?
        relevant? && !array_arg
      end
    end
  end
end
