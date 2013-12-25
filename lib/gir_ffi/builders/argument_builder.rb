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
        if has_input_value? && !is_array_length_parameter?
          name
        end
      end

      def post_converted_name
        @post_converted_name ||= if has_post_conversion?
                                   new_variable
                                 else
                                   callarg
                                 end
      end

      def return_value_name
        if has_output_value?
          post_converted_name unless is_array_length_parameter?
        end
      end

      def pre_conversion
        pr = []
        if skipped?
          value = direction == :in ? "0" : "nil"
          pr << "#{callarg} = #{value}"
        else
          case direction
          when :in
            pr << fixed_array_size_check if needs_size_check?
            pr << array_length_assignment if is_array_length_parameter?
            pr << "#{callarg} = #{ingoing_convertor.conversion}"
          when :inout
            pr << fixed_array_size_check if needs_size_check?
            pr << array_length_assignment if is_array_length_parameter?
            pr << out_parameter_preparation
            pr << "#{callarg}.set_value #{ingoing_convertor.conversion}"
          when :out
            pr << out_parameter_preparation
          end
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
        has_output_value? && !is_caller_allocated_object?
      end

      def output_value
        base = "#{callarg}.to_value"
        if @type_info.needs_conversion_for_functions?
          CToRubyConvertor.new(@type_info, base, length_argument_name).conversion
        else
          base
        end
      end

      def length_argument_name
        length_arg && length_arg.post_converted_name
      end

      def is_array_length_parameter?
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
        value = if is_caller_allocated_object?
                  if specialized_type_tag == :array
                    "#{argument_class_name}.new #{type_info.element_type.inspect}"
                  else
                    "#{argument_class_name}.new"
                  end
                else
                  "GirFFI::InOutPointer.for #{type_info.tag_or_class.inspect}"
                end
        "#{callarg} = #{value}"
      end

      def is_caller_allocated_object?
        [ :struct, :array ].include?(specialized_type_tag) &&
          @arginfo.caller_allocates?
      end

      def ingoing_convertor
        if is_closure
          ClosureToPointerConvertor.new(name)
        elsif @type_info.needs_ruby_to_c_conversion_for_functions?
          RubyToCConvertor.new(@type_info, name)
        else
          NullConvertor.new(name)
        end
      end
    end
  end
end
