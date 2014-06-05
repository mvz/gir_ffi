require 'gir_ffi/builders/base_argument_builder'
require 'gir_ffi/builders/c_to_ruby_convertor'
require 'gir_ffi/builders/closure_convertor'
require 'gir_ffi/builders/null_convertor'

module GirFFI
  module Builders
    # Convertor for arguments for RubyClosure objects. Used when building the
    # marshaller for signal handler closures.
    class ClosureArgumentBuilder < BaseArgumentBuilder
      def method_argument_name
        @method_argument_name ||= name || new_variable
      end

      def pre_converted_name
        @pre_converted_name ||= new_variable
      end

      def call_argument_name
        if direction == :in
          pre_converted_name unless array_arg
        end
      end

      def capture_variable_name
        result_name if direction == :out
      end

      def pre_conversion
        case direction
        when :in
          [ "#{pre_converted_name} = #{pre_convertor.conversion}" ]
        when :out
          [ "#{pre_converted_name} = #{out_parameter_preparation}" ]
        when :error
          [
            "#{pre_converted_name} = #{out_parameter_preparation}",
            "begin"
          ]
        end
      end

      def post_conversion
        case direction
        when :out
          [ outgoing_post_conversion ]
        when :error
          [
            "rescue => #{result_name}",
            outgoing_post_conversion,
            "end"
          ]
        else
          []
        end
      end

      private

      def result_name
        @result_name ||= new_variable
      end

      def pre_convertor
        @pre_convertor ||= if is_closure
                             ClosureConvertor.new(method_argument_name)
                           elsif type_info.needs_c_to_ruby_conversion_for_closures?
                             CToRubyConvertor.new(type_info,
                                                  method_argument_name,
                                                  length_argument_name)
                           else
                             NullConvertor.new(method_argument_name)
                           end
      end

      def outgoing_post_conversion
        "#{pre_converted_name}.set_value #{outgoing_convertor.conversion}"
      end

      def outgoing_convertor
        @outgoing_convertor ||= if type_info.needs_ruby_to_c_conversion_for_callbacks?
                                  RubyToCConvertor.new(type_info, result_name)
                                else
                                  NullConvertor.new(result_name)
                                end
      end

      def out_parameter_preparation
        type_spec = type_info.tag_or_class
        if allocated_by_us?
          "GirFFI::InOutPointer.new(#{type_spec[1].inspect})" +
            ".tap { |ptr| #{method_argument_name}.put_pointer 0, ptr }"
        else
          "GirFFI::InOutPointer.new(#{type_spec.inspect}, #{method_argument_name})"
        end
      end

      # Check if an out argument needs to be allocated by us, the callee. Since
      # caller_allocates is false by default, we must also check that the type
      # is a pointer. For example, an out parameter of type gint8* will always
      # be allocate by the caller.
      def allocated_by_us?
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

