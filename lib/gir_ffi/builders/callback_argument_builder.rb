# frozen_string_literal: true
require 'gir_ffi/builders/base_argument_builder'
require 'gir_ffi/builders/c_to_ruby_convertor'
require 'gir_ffi/builders/closure_convertor'
require 'gir_ffi/builders/null_convertor'

module GirFFI
  module Builders
    # Convertor for arguments for ruby callbacks. Used when building the
    # argument mapper for callbacks.
    class CallbackArgumentBuilder < BaseArgumentBuilder
      def method_argument_name
        @method_argument_name ||= name || new_variable
      end

      def block_argument?
        false
      end

      def allow_none?
        false
      end

      def pre_converted_name
        @pre_converted_name ||= new_variable
      end

      def out_parameter_name
        @out_parameter_name ||=
          if direction == :inout
            new_variable
          else
            pre_converted_name
          end
      end

      def call_argument_name
        if [:in, :inout].include? direction
          pre_converted_name unless array_arg
        end
      end

      def capture_variable_name
        unless array_arg
          result_name if [:out, :inout].include? direction
        end
      end

      def pre_conversion
        case direction
        when :in
          [ingoing_pre_conversion]
        when :out
          [out_parameter_preparation]
        when :inout
          [out_parameter_preparation, ingoing_pre_conversion]
        when :error
          [out_parameter_preparation, 'begin']
        end
      end

      def post_conversion
        case direction
        when :out, :inout
          [outgoing_post_conversion]
        when :error
          [
            "rescue => #{result_name}",
            outgoing_post_conversion,
            'end'
          ]
        else
          []
        end
      end

      private

      def result_name
        @result_name ||= new_variable
      end

      def pre_convertor_argument
        if direction == :inout
          "#{out_parameter_name}.to_value"
        else
          method_argument_name
        end
      end

      def pre_convertor
        @pre_convertor ||= if closure?
                             ClosureConvertor.new(pre_convertor_argument)
                           elsif needs_c_to_ruby_conversion?
                             CToRubyConvertor.new(type_info,
                                                  pre_convertor_argument,
                                                  length_argument_name)
                           else
                             NullConvertor.new(pre_convertor_argument)
                           end
      end

      def needs_c_to_ruby_conversion?
        type_info.needs_c_to_ruby_conversion_for_callbacks?
      end

      def ingoing_pre_conversion
        "#{pre_converted_name} = #{pre_convertor.conversion}"
      end

      def outgoing_post_conversion
        "#{out_parameter_name}.set_value #{post_convertor.conversion}"
      end

      def post_convertor
        @post_convertor ||= if type_info.needs_ruby_to_c_conversion_for_callbacks?
                              RubyToCConvertor.new(type_info, post_convertor_argument)
                            else
                              NullConvertor.new(post_convertor_argument)
                            end
      end

      def post_convertor_argument
        if array_arg
          "#{array_arg.capture_variable_name}.length"
        else
          result_name
        end
      end

      def out_parameter_preparation
        type_spec = type_info.tag_or_class
        value = if allocated_by_us?
                  "GirFFI::InOutPointer.allocate_new(#{type_spec[1].inspect})" \
                    ".tap { |ptr| #{method_argument_name}.put_pointer 0, ptr }"
                else
                  "GirFFI::InOutPointer.new(#{type_spec.inspect}, #{method_argument_name})"
                end
        "#{out_parameter_name} = #{value}"
      end

      # Check if an out argument needs to be allocated by us, the callee. Since
      # caller_allocates is false by default, we must also check that the type
      # is a pointer. For example, an out parameter of type gint8* will always
      # be allocate by the caller.
      def allocated_by_us?
        direction == :out &&
          !@arginfo.caller_allocates? &&
          type_info.pointer? &&
          ![:object, :zero_terminated].include?(specialized_type_tag)
      end

      def length_argument_name
        length_arg && length_arg.pre_converted_name
      end
    end
  end
end
