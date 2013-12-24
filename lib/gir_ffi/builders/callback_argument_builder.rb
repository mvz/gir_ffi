require 'gir_ffi/builders/base_argument_builder'
require 'gir_ffi/builders/c_to_ruby_convertor'
require 'gir_ffi/builders/closure_convertor'

module GirFFI
  module Builders
    class CallbackArgumentBuilder < BaseArgumentBuilder
      def method_argument_name
        @method_argument_name ||= name || new_variable
      end

      def pre_converted_name
        @pre_converted_name ||= if has_pre_conversion?
                                  new_variable
                                else
                                  method_argument_name
                                end
      end

      def call_argument_name
        pre_converted_name unless array_arg
      end

      def pre_conversion
        if has_pre_conversion?
          [ "#{pre_converted_name} = #{pre_convertor.conversion}" ]
        else
          []
        end
      end

      private

      def has_pre_conversion?
        is_closure || type_info.needs_conversion_for_callbacks?
      end

      def pre_convertor
        @pre_convertor ||= if is_closure
                             ClosureConvertor.new(method_argument_name)
                           else
                             CToRubyConvertor.new(type_info,
                                                  method_argument_name,
                                                  length_argument_name)
                           end
      end

      def length_argument_name
        length_arg && length_arg.pre_converted_name
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
