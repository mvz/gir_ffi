require 'gir_ffi/builders/base_argument_builder'

module GirFFI
  module Builders
    # Implements building pre- and post-processing statements for arguments.
    class ArgumentBuilder < BaseArgumentBuilder
      def initialize var_gen, arginfo
        super var_gen, arginfo.name, arginfo.argument_type, arginfo.direction
        @arginfo = arginfo
      end

      def inarg
        if has_input_value? && !is_array_length_parameter?
          @name
        end
      end

      def retname
        if has_output_value?
          @retname ||= @var_gen.new_var
        end
      end

      def pre
        pr = []
        if has_input_value?
          pr << fixed_array_size_check if needs_size_check?
          pr << array_length_assignment if is_array_length_parameter?
        end
        pr << set_function_call_argument
        pr
      end

      def post
        if has_output_value?
          value = output_value
          ["#{retname} = #{value}"]
        else
          []
        end
      end

      private

      def output_value
        if is_caller_allocated_object?
          callarg
        else
          base = "#{callarg}.to_value"
          if needs_outgoing_parameter_conversion?
            outgoing_conversion base
          else
            base
          end
        end
      end

      def is_array_length_parameter?
        @array_arg
      end

      def needs_size_check?
        specialized_type_tag == :c && type_info.array_fixed_size > -1
      end

      def fixed_array_size_check
        size = type_info.array_fixed_size
        "GirFFI::ArgHelper.check_fixed_array_size #{size}, #{@name}, \"#{@name}\""
      end

      def skipped?
        @arginfo.skip? ||
          @array_arg && @array_arg.specialized_type_tag == :strv
      end

      def has_output_value?
        (@direction == :inout || @direction == :out) && !skipped?
      end

      def has_input_value?
        (@direction == :inout || @direction == :in) && !skipped?
      end

      def array_length_assignment
        arrname = @array_arg.name
        "#{@name} = #{arrname}.nil? ? 0 : #{arrname}.length"
      end

      def set_function_call_argument
        value = if skipped?
                  @direction == :in ? "0" : "nil"
                elsif !has_input_value?
                  out_parameter_preparation
                else
                  ingoing_parameter_conversion
                end
        "#{callarg} = #{value}"
      end

      def out_parameter_preparation
        if is_caller_allocated_object?
          if specialized_type_tag == :array
            "#{argument_class_name}.new #{type_info.element_type.inspect}"
          else
            "#{argument_class_name}.new"
          end
        else
          "GirFFI::InOutPointer.for #{type_info.tag_or_class.inspect}"
        end
      end

      def is_caller_allocated_object?
        [ :struct, :array ].include?(specialized_type_tag) &&
          @arginfo.caller_allocates?
      end

      def ingoing_parameter_conversion
        args = conversion_arguments @name

        base = case specialized_type_tag
               when :array, :c, :callback, :ghash, :glist, :gslist, :object, :ptr_array,
                 :struct, :strv, :utf8, :void, :zero_terminated
                 "#{argument_class_name}.from(#{args})"
               else
                 args
               end

        if has_output_value?
          "GirFFI::InOutPointer.from #{type_info.tag_or_class.inspect}, #{base}"
        else
          base
        end
      end
    end
  end
end
