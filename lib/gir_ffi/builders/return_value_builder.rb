require 'gir_ffi/builders/base_argument_builder'
require 'gir_ffi/builders/c_to_ruby_convertor'
require 'gir_ffi/builders/closure_convertor'
require 'gir_ffi/builders/constructor_result_convertor'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values.
    class ReturnValueBuilder < BaseArgumentBuilder
      def initialize var_gen, arginfo, constructor_result = false
        super var_gen, arginfo
        @constructor_result = constructor_result
      end

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
          ["#{post_converted_name} = #{post_convertor.conversion}"]
        else
          []
        end
      end

      private

      def constructor_result?
        @constructor_result
      end

      def has_post_conversion?
        closure? || constructor_result? ||
          type_info.needs_c_to_ruby_conversion_for_functions?
      end

      def post_convertor
        @post_convertor ||= if closure?
                              ClosureConvertor.new(capture_variable_name)
                            elsif constructor_result?
                              ConstructorResultConvertor.new(capture_variable_name)
                            else
                              CToRubyConvertor.new(type_info,
                                                   capture_variable_name,
                                                   length_argument_name)
                            end
      end

      def length_argument_name
        length_arg && length_arg.post_converted_name
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
