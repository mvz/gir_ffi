# frozen_string_literal: true

require 'gir_ffi/builders/base_argument_builder'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values of
    # callbacks.
    class BaseReturnValueBuilder < BaseArgumentBuilder
      def relevant?
        !void_return_value? && !arginfo.skip?
      end

      def capture_variable_name
        @capture_variable_name ||= new_variable if relevant?
      end

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

      def void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end

      def has_return_value_name?
        relevant? && !array_arg
      end
    end
  end
end
