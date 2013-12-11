require 'gir_ffi/builders/base_argument_builder'
require 'gir_ffi/builders/c_to_ruby_convertor'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values.
    class ReturnValueBuilder < BaseArgumentBuilder
      def initialize var_gen, arginfo, is_constructor = false
        super var_gen, arginfo
        @is_constructor = is_constructor
      end

      def post_conversion
        if has_post_conversion?
          [ "#{post_converted_name} = #{post_conversion_implementation}" ]
        else
          []
        end
      end

      def inarg
        nil
      end

      def return_value_name
        if is_relevant?
          post_converted_name unless array_arg
        end
      end

      def is_relevant?
        !is_void_return_value? && !arginfo.skip?
      end

      def post_converted_name
        @post_converted_name ||= if has_post_conversion?
                       @var_gen.new_var
                     else
                       capture_variable_name
                     end
      end

      def capture_variable_name
        @capture_variable_name ||= new_variable
      end

      private

      def has_post_conversion?
        is_closure || needs_constructor_wrap? ||
          type_info.needs_conversion_for_functions?
      end

      def post_convertor
        @post_convertor ||= if is_closure
                              ClosureConvertor.new(capture_variable_name)
                            else
                              CToRubyConvertor.new(type_info,
                                                   capture_variable_name,
                                                   length_argument_name)
                            end
      end

      def length_argument_name
        length_arg && length_arg.retname
      end

      def post_conversion_implementation
        if needs_constructor_wrap?
          "self.constructor_wrap(#{capture_variable_name})"
        else
          post_convertor.conversion
        end
      end

      def needs_constructor_wrap?
        @is_constructor && specialized_type_tag == :object
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
