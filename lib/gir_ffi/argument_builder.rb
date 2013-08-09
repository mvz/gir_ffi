require 'gir_ffi/base_argument_builder'

module GirFFI
  # Implements building pre- and post-processing statements for arguments.
  class ArgumentBuilder < BaseArgumentBuilder
    def initialize var_gen, arginfo
      super var_gen, arginfo.name, arginfo.argument_type, arginfo.direction
      @arginfo = arginfo
    end

    def inarg
      if has_input_value?
        @array_arg.nil? ? @name : nil
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
      elsif needs_outgoing_parameter_conversion?
        case specialized_type_tag
        when :enum, :flags
          "#{argument_class_name}[#{output_conversion_arguments}]"
        when :utf8
          "#{callarg}.to_value.to_utf8"
        else
          "#{argument_class_name}.wrap(#{output_conversion_arguments})"
        end
      else
        "#{callarg}.to_value"
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

    def has_output_value?
      @direction == :inout || @direction == :out
    end

    def has_input_value?
      @direction == :inout || @direction == :in
    end

    def array_length_assignment
      arrname = @array_arg.name
      "#{@name} = #{arrname}.nil? ? 0 : #{arrname}.length"
    end

    def set_function_call_argument
      value = if @direction == :out
                if is_caller_allocated_object?
                  if specialized_type_tag == :array
                    "#{argument_class_name}.new #{elm_t}"
                  else
                    "#{argument_class_name}.new"
                  end
                else
                  "GirFFI::InOutPointer.for #{specialized_type_tag.inspect}"
                end
              else
                if needs_ingoing_parameter_conversion?
                  ingoing_parameter_conversion
                else
                  @name
                end
              end
      "#{callarg} = #{value}"
    end

    def is_caller_allocated_object?
      [ :struct, :array ].include?(specialized_type_tag) &&
        @arginfo.caller_allocates?
    end

    def needs_outgoing_parameter_conversion?
      [ :array, :c, :enum, :error, :flags, :ghash, :glist, :gslist, :object,
        :ptr_array, :struct, :strv, :utf8 ].include?(specialized_type_tag)
    end

    def needs_ingoing_parameter_conversion?
      @direction == :inout ||
        [ :array, :c, :callback, :ghash, :glist, :gslist, :object, :ptr_array,
          :struct, :strv, :utf8, :void, :zero_terminated ].include?(specialized_type_tag)
    end

    def ingoing_parameter_conversion
      case specialized_type_tag
      when :enum, :flags
        base = "#{argument_class_name}[#{parameter_conversion_arguments}]"
      when :array, :c, :callback, :ghash, :glist, :gslist, :object, :ptr_array,
        :struct, :strv, :utf8, :void, :zero_terminated
        base = "#{argument_class_name}.from(#{parameter_conversion_arguments})"
      else
        base = "#{parameter_conversion_arguments}"
      end

      if has_output_value?
        "GirFFI::InOutPointer.from #{specialized_type_tag.inspect}, #{base}"
      else
        base
      end
    end

    def output_conversion_arguments
      if specialized_type_tag == :c
        "#{subtype_tag_or_class_name}, #{array_size}, #{callarg}.to_value"
      else
        conversion_arguments "#{callarg}.to_value"
      end
    end

    def parameter_conversion_arguments
      conversion_arguments @name
    end
  end
end
