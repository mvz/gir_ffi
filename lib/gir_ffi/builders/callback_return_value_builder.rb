# frozen_string_literal: true

require 'gir_ffi/builders/base_return_value_builder'
require 'gir_ffi/builders/ruby_to_c_convertor'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values of
    # callbacks.
    class CallbackReturnValueBuilder < BaseReturnValueBuilder
      def post_conversion
        if has_post_conversion?
          optional_outgoing_ref + base_post_conversion
        else
          []
        end
      end

      private

      def has_post_conversion?
        relevant? && needs_ruby_to_c_conversion?
      end

      def needs_ruby_to_c_conversion?
        type_info.needs_ruby_to_c_conversion_for_callbacks?
      end

      def optional_outgoing_ref
        if outgoing_ref_needed?
          ["#{capture_variable_name}.ref"]
        else
          []
        end
      end

      def base_post_conversion
        if specialized_type_tag == :object
          ["#{post_converted_name} = #{post_convertor.conversion}.to_ptr"]
        else
          ["#{post_converted_name} = #{post_convertor.conversion}"]
        end
      end

      def post_convertor
        @post_convertor ||= RubyToCConvertor.new(type_info, capture_variable_name)
      end

      def outgoing_ref_needed?
        ownership_transfer == :everything && specialized_type_tag == :object
      end
    end
  end
end
