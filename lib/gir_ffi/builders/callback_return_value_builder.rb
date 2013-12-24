require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/builders/ruby_to_c_convertor'

module GirFFI
  module Builders
    class CallbackReturnValueBuilder < BaseArgumentBuilder
      def is_relevant?
        !is_void_return_value? && !arginfo.skip?
      end

      def capture_variable_name
        @capture_variable_name ||= new_variable
      end

      def post_converted_name
        @post_converted_name ||= if has_post_conversion?
                                   new_variable
                                 else
                                   capture_variable_name
                                 end
      end

      def return_value_name
        if is_relevant?
          post_converted_name unless array_arg
        end
      end

      def post_conversion
        if has_post_conversion?
          [ "#{post_converted_name} = #{post_convertor.conversion}" ]
        else
          []
        end
      end

      private

      def has_post_conversion?
        type_info.needs_conversion_for_callbacks?
      end

      def post_convertor
        @post_convertor ||= RubyToCConvertor.new(type_info, capture_variable_name)
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
