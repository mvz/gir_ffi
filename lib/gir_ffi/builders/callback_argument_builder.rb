require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/builders/c_to_ruby_convertor'

module GirFFI
  module Builders
    class CallbackArgumentBuilder < BaseArgumentBuilder
      def pre_conversion
        if has_pre_conversion?
          [ "#{pre_converted_name} = #{pre_conversion_implementation}" ]
        else
          []
        end
      end

      def call_argument_name
        pre_converted_name unless array_arg
      end

      def pre_converted_name
        @pre_converted_name ||= if has_pre_conversion?
                                  new_variable
                                else
                                  method_argument_name
                                end
      end

      def method_argument_name
        @method_argument_name ||= name || new_variable
      end

      private

      def has_pre_conversion?
        is_closure || type_info.needs_conversion_for_callbacks?
      end

      def pre_convertor
        @pre_convertor ||= CToRubyConvertor.new(type_info,
                                                method_argument_name,
                                                length_argument_name)
      end

      def length_argument_name
        length_arg && length_arg.pre_converted_name
      end

      def pre_conversion_implementation
        if is_closure
          "GirFFI::ArgHelper::OBJECT_STORE[#{method_argument_name}.address]"
        else
          pre_convertor.conversion
        end
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
