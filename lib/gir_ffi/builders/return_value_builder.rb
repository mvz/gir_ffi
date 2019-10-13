# frozen_string_literal: true

require "gir_ffi/builders/base_return_value_builder"
require "gir_ffi/builders/full_c_to_ruby_convertor"
require "gir_ffi/builders/closure_convertor"

module GirFFI
  module Builders
    # Implements building post-processing statements for return values.
    class ReturnValueBuilder < BaseReturnValueBuilder
      def post_conversion
        result = []
        if has_post_conversion?
          result << "#{post_converted_name} = #{post_convertor.conversion}"
        end
        result
      end

      def has_post_conversion?
        user_data? || needs_c_to_ruby_conversion?
      end

      def needs_c_to_ruby_conversion?
        type_info.needs_c_to_ruby_conversion_for_functions?
      end

      private

      def post_convertor
        @post_convertor ||=
          if user_data?
            ClosureConvertor.new(capture_variable_name)
          else
            FullCToRubyConvertor.new(type_info,
                                     capture_variable_name,
                                     length_argument_name,
                                     ownership_transfer: arginfo.ownership_transfer)
          end
      end

      def length_argument_name
        length_arg&.post_converted_name
      end
    end
  end
end
