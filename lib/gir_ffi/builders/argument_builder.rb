# frozen_string_literal: true

require "gir_ffi/builders/base_argument_builder"
require "gir_ffi/builders/closure_to_pointer_convertor"
require "gir_ffi/builders/full_c_to_ruby_convertor"
require "gir_ffi/builders/ruby_to_c_convertor"
require "gir_ffi/builders/pointer_value_convertor"
require "gir_ffi/builders/null_convertor"

module GirFFI
  module Builders
    # Implements building pre- and post-processing statements for arguments.
    class ArgumentBuilder < BaseArgumentBuilder
      def method_argument_name
        name if has_input_value? && !helper_argument?
      end

      def block_argument?
        specialized_type_tag == :callback
      end

      def allow_none?
        arginfo.may_be_null?
      end

      def post_converted_name
        @post_converted_name ||= if has_post_conversion?
                                   new_variable
                                 else
                                   call_argument_name
                                 end
      end

      def return_value_name
        post_converted_name if has_output_value? && !array_length_parameter?
      end

      def capture_variable_name
        nil
      end

      def pre_conversion
        case direction
        when :in
          pre_conversion_in
        when :inout
          pre_conversion_inout
        when :out
          pre_conversion_out
        when :error
          pre_conversion_error
        end
      end

      def post_conversion
        if direction == :error
          ["GirFFI::ArgHelper.check_error(#{call_argument_name})"]
        elsif has_post_conversion?
          value = output_value
          ["#{post_converted_name} = #{value}"]
        else
          []
        end
      end

      private

      def pre_conversion_in
        pr = []
        pr << fixed_array_size_check if needs_size_check?
        pr << array_length_assignment if array_length_parameter?
        pr << "#{call_argument_name} = #{ingoing_convertor.conversion}"
        pr
      end

      def pre_conversion_inout
        pr = []
        pr << fixed_array_size_check if needs_size_check?
        pr << array_length_assignment if array_length_parameter?
        pr << out_parameter_preparation
        pr << ingoing_value_storage
        pr
      end

      def pre_conversion_out
        [out_parameter_preparation]
      end

      def pre_conversion_error
        ["#{call_argument_name} = FFI::MemoryPointer.new(:pointer).write_pointer nil"]
      end

      def ingoing_value_storage
        PointerValueConvertor.new(type_spec)
          .value_to_pointer(call_argument_name, ingoing_convertor.conversion)
      end

      def has_post_conversion?
        has_output_value? && (!caller_allocated_object? || gvalue?)
      end

      def output_value
        return "#{call_argument_name}.get_value" if caller_allocated_object? && gvalue?

        base = pointer_to_value_method_call call_argument_name, type_spec
        if needs_out_conversion?
          outgoing_convertor(base).conversion
        elsif allocated_by_them? && specialized_type_tag != :void
          pointer_to_value_method_call base, sub_type_spec
        else
          base
        end
      end

      def outgoing_convertor(base)
        FullCToRubyConvertor.new(type_info, base, length_argument_name,
                                 ownership_transfer: arginfo.ownership_transfer)
      end

      def sub_type_spec
        type_spec[1]
      end

      def pointer_to_value_method_call(ptr_exp, spec)
        PointerValueConvertor.new(spec).pointer_to_value(ptr_exp)
      end

      def needs_out_conversion?
        type_info.needs_c_to_ruby_conversion_for_functions?
      end

      def gvalue?
        type_info.gvalue?
      end

      # Check if an out argument needs to be allocated by them, the callee. Since
      # caller_allocates is false by default, we must also check that the type
      # is a pointer. For example, an out parameter of type gint8* will always
      # be allocated by the caller (that's us).
      def allocated_by_them?
        !arginfo.caller_allocates? && type_info.pointer?
      end

      def length_argument_name
        length_arg&.post_converted_name
      end

      def needs_size_check?
        specialized_type_tag == :c && type_info.array_fixed_size > -1
      end

      def fixed_array_size_check
        size = type_info.array_fixed_size
        "GirFFI::ArgHelper.check_fixed_array_size #{size}, #{name}, \"#{name}\""
      end

      def skipped_in?
        arginfo.skip?
      end

      def skipped_out?
        arginfo.skip? ||
          array_arg && array_arg.specialized_type_tag == :strv
      end

      def has_output_value?
        (direction == :inout || direction == :out) && !skipped_out?
      end

      def has_input_value?
        has_ingoing_component? && !skipped_in?
      end

      def has_ingoing_component?
        direction == :inout || direction == :in
      end

      def array_length_assignment
        arrname = array_arg.name
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
                  ffi_type_spec = TypeMap.type_specification_to_ffi_type type_spec
                  "FFI::MemoryPointer.new #{ffi_type_spec.inspect}"
                end
        "#{call_argument_name} = #{value}"
      end

      def type_spec
        type_info.tag_or_class
      end

      def caller_allocated_object?
        [:struct, :array].include?(specialized_type_tag) &&
          arginfo.caller_allocates?
      end

      DESTROY_NOTIFIER = "GLib::DestroyNotify.default"

      def ingoing_convertor
        if skipped_in?
          NullConvertor.new("0")
        elsif destroy_notifier?
          NullConvertor.new(DESTROY_NOTIFIER)
        elsif user_data?
          ClosureToPointerConvertor.new(callback_argument_name)
        elsif needs_ruby_to_c_conversion?
          RubyToCConvertor.new(type_info, pre_convertor_argument,
                               ownership_transfer: ownership_transfer)
        else
          NullConvertor.new(pre_convertor_argument)
        end
      end

      def pre_convertor_argument
        if ownership_transfer == :everything && specialized_type_tag == :object
          "#{name} && #{name}.ref"
        else
          name
        end
      end

      def needs_ruby_to_c_conversion?
        type_info.needs_ruby_to_c_conversion_for_functions?
      end

      def callback_argument_name
        related_callback_builder.call_argument_name
      end
    end
  end
end
