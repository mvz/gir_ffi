require 'gir_ffi/builders/base_argument_builder'
require 'gir_ffi/builders/closure_to_pointer_convertor'
require 'gir_ffi/builders/c_to_ruby_convertor'
require 'gir_ffi/builders/ruby_to_c_convertor'
require 'gir_ffi/builders/null_convertor'

module GirFFI
  module Builders
    # Implements building pre- and post-processing statements for arguments.
    class ArgumentBuilder < BaseArgumentBuilder
      def method_argument_name
        name if has_input_value? && !array_length_parameter?
      end

      def post_converted_name
        @post_converted_name ||= if has_post_conversion?
                                   new_variable
                                 else
                                   call_argument_name
                                 end
      end

      def return_value_name
        if has_output_value?
          post_converted_name unless array_length_parameter?
        end
      end

      def capture_variable_name
        nil
      end

      def pre_conversion
        pr = []
        case direction
        when :in
          pr << fixed_array_size_check if needs_size_check?
          pr << array_length_assignment if array_length_parameter?
          pr << "#{call_argument_name} = #{ingoing_convertor.conversion}"
        when :inout
          pr << fixed_array_size_check if needs_size_check?
          pr << array_length_assignment if array_length_parameter?
          pr << out_parameter_preparation
          pr << "#{call_argument_name}.set_value #{ingoing_convertor.conversion}"
        when :out
          pr << out_parameter_preparation
        end
        pr
      end

      def post_conversion
        if has_post_conversion?
          value = output_value
          ["#{post_converted_name} = #{value}"]
        else
          []
        end
      end

      private

      def has_post_conversion?
        has_output_value? && !caller_allocated_object?
      end

      def output_value
        base = "#{call_argument_name}.to_value"
        if needs_out_conversion?
          CToRubyConvertor.new(@type_info, base, length_argument_name).conversion
        elsif allocated_by_them?
          "GirFFI::InOutPointer.new(#{type_info.tag_or_class[1].inspect}, #{base}).to_value"
        else
          base
        end
      end

      def needs_out_conversion?
        @type_info.needs_c_to_ruby_conversion_for_functions?
      end

      # Check if an out argument needs to be allocated by them, the callee. Since
      # caller_allocates is false by default, we must also check that the type
      # is a pointer. For example, an out parameter of type gint8* will always
      # be allocated by the caller (that's us).
      def allocated_by_them?
        !@arginfo.caller_allocates? && @type_info.pointer?
      end

      def length_argument_name
        length_arg && length_arg.post_converted_name
      end

      def array_length_parameter?
        @array_arg
      end

      def needs_size_check?
        specialized_type_tag == :c && type_info.array_fixed_size > -1
      end

      def fixed_array_size_check
        size = type_info.array_fixed_size
        "GirFFI::ArgHelper.check_fixed_array_size #{size}, #{name}, \"#{name}\""
      end

      def skipped?
        @arginfo.skip? ||
          @array_arg && @array_arg.specialized_type_tag == :strv
      end

      def has_output_value?
        (direction == :inout || direction == :out) && !skipped?
      end

      def has_input_value?
        (direction == :inout || direction == :in) && !skipped?
      end

      def array_length_assignment
        arrname = @array_arg.name
        "#{name} = #{arrname}.nil? ? 0 : #{arrname}.length"
      end

      def out_parameter_preparation
        value = if caller_allocated_object?
                  if specialized_type_tag == :array
                    "#{argument_class_name}.new #{type_info.element_type.inspect}"
                  else
                    "#{argument_class_name}.new"
                  end
                else
                  "GirFFI::InOutPointer.for #{type_info.tag_or_class.inspect}"
                end
        "#{call_argument_name} = #{value}"
      end

      def caller_allocated_object?
        [:struct, :array].include?(specialized_type_tag) &&
          @arginfo.caller_allocates?
      end

      def ingoing_convertor
        if skipped?
          NullConvertor.new('0')
        elsif closure?
          ClosureToPointerConvertor.new(pre_convertor_argument)
        elsif @type_info.needs_ruby_to_c_conversion_for_functions?
          RubyToCConvertor.new(@type_info, pre_convertor_argument)
        else
          NullConvertor.new(pre_convertor_argument)
        end
      end

      def pre_convertor_argument
        if ownership_transfer == :everything && specialized_type_tag == :object
          "#{name}.ref"
        else
          name
        end
      end
    end
  end
end
