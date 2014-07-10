require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/builders/ruby_to_c_convertor'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values of
    # callbacks.
    class CallbackReturnValueBuilder < BaseArgumentBuilder
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

      private

      def has_post_conversion?
        type_info.needs_c_to_ruby_conversion_for_callbacks?
      end

      def post_convertor
        @post_convertor ||= RubyToCConvertor.new(type_info, capture_variable_name)
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
