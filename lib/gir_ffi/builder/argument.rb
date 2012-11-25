require 'forwardable'

require 'gir_ffi/builder/argument/base'

module GirFFI::Builder
  # Implements argument processing for arguments not handled by more specific
  # builders.
  class RegularArgument < Argument::Base
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
      result = []
      if has_output_value?
        value = if is_caller_allocated_object?
                  callarg
                elsif needs_outgoing_parameter_conversion?
                  case specialized_type_tag
                  when :enum, :flags
                    "#{argument_class_name}[#{output_conversion_arguments}]"
                  else
                    "#{argument_class_name}.wrap(#{output_conversion_arguments})"
                  end
                elsif is_fixed_length_array?
                  "#{callarg}.to_sized_array_value #{array_size}"
                else
                  "#{callarg}.to_value"
                end
        result << "#{retname} = #{value}"
      end
      result
    end

    private

    def is_array_length_parameter?
      @array_arg
    end

    def needs_size_check?
      specialized_type_tag == :c && type_info.array_fixed_size > -1
    end

    def is_fixed_length_array?
      specialized_type_tag == :c
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
                  "#{argument_class_name}.allocate"
                else
                  "GirFFI::InOutPointer.for #{type_specification}"
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
      [:object, :struct].include?(specialized_type_tag) &&
        @arginfo.caller_allocates?
    end

    def needs_outgoing_parameter_conversion?
      [ :array, :enum, :flags, :ghash, :glist, :gslist, :object, :struct,
        :strv ].include?(specialized_type_tag)
    end

    def needs_ingoing_parameter_conversion?
      @direction == :inout ||
        [ :object, :struct, :callback, :utf8, :void, :glist, :gslist, :ghash,
          :array, :c, :zero_terminated, :strv ].include?(specialized_type_tag)
    end

    def ingoing_parameter_conversion
      case specialized_type_tag
      when :enum, :flags
        base = "#{argument_class_name}[#{parameter_conversion_arguments}]"
        "GirFFI::InOutPointer.from #{specialized_type_tag.inspect}, #{base}"
      when :object, :struct, :void, :glist, :gslist, :ghash, :array,
        :zero_terminated, :strv, :callback
        base = "#{argument_class_name}.from(#{parameter_conversion_arguments})"
        if has_output_value?
          if specialized_type_tag == :strv
            "GirFFI::InOutPointer.from #{type_specification}, #{base}"
          else
            "GirFFI::InOutPointer.from :pointer, #{base}"
          end
        else
          base
        end
      when :c, :utf8
        if has_output_value?
          "GirFFI::InOutPointer.from #{parameter_conversion_arguments}"
        else
          "GirFFI::InPointer.from(#{parameter_conversion_arguments})"
        end
      else
        base = "#{parameter_conversion_arguments}"
        "GirFFI::InOutPointer.from #{specialized_type_tag.inspect}, #{base}"
      end
    end

    def output_conversion_arguments
      conversion_arguments "#{callarg}.to_value"
    end

    def parameter_conversion_arguments
      conversion_arguments @name
    end

    def self_t
      type_tag.inspect
    end
  end

  module ReturnValueFactory
    def self.build var_gen, arginfo
      builder_for(var_gen,
                  arginfo.name,
                  arginfo.return_type,
                  :return,
                  arginfo.constructor?)
    end

    def self.builder_for var_gen, name, type, direction, is_constructor
      case type.flattened_tag
      when :interface, :object
        klass = if is_constructor
                  ConstructorReturnValue
                else
                  RegularReturnValue
                end
        klass.new var_gen, name, type
      else
        builder_for_field_getter var_gen, name, type, direction
      end
    end

    def self.builder_for_field_getter var_gen, name, type, direction
      RegularReturnValue.new var_gen, name, type
    end
  end

  # Implements argument processing for return values.
  class ReturnValue < Argument::Base
    def initialize var_gen, name, type_info
      super var_gen, name, type_info, :return
    end

    def cvar
      callarg
    end

    def retname
      @retname ||= @var_gen.new_var
    end

    def inarg
      nil
    end
  end

  # Implements argument processing for object constructors.
  class ConstructorReturnValue < ReturnValue
    def post
      [ "#{retname} = self.constructor_wrap(#{cvar})" ]
    end
  end

  # Implements argument processing for return values.
  class RegularReturnValue < ReturnValue
    def post
      if needs_wrapping?
        if specialized_type_tag == :zero_terminated
          # FIXME: This is almost certainly wrong and needs the be the same as
          # the other branch of this if statement.
          [ "#{retname} = #{argument_class_name}.wrap(#{cvar})" ]
        else
          [ "#{retname} = #{argument_class_name}.wrap(#{return_value_conversion_arguments})" ]
        end
      elsif specialized_type_tag == :utf8
        # TODO: Re-use methods in InOutPointer for this conversion
        [ "#{retname} = GirFFI::ArgHelper.ptr_to_utf8(#{cvar})" ]
      elsif specialized_type_tag == :c
        size = array_size
        [ "#{retname} = GirFFI::ArgHelper.ptr_to_typed_array #{subtype_tag_or_class_name}, #{cvar}, #{size}" ]
      else
        []
      end
    end

    # TODO: Rename
    def cvar
      callarg unless is_void_return_value?
    end

    def retval
      if has_conversion?
        super
      elsif is_void_return_value?
        nil
      else
        callarg
      end
    end

    private

    def has_conversion?
      needs_wrapping? || [ :utf8, :c ].include?(specialized_type_tag)
    end

    def needs_wrapping?
      [ :struct, :union, :interface, :object, :strv, :zero_terminated,
        :byte_array, :ptr_array, :glist, :gslist, :ghash, :array
      ].include?(specialized_type_tag)
    end

    def is_void_return_value?
      specialized_type_tag == :void && !type_info.pointer?
    end

    def return_value_conversion_arguments
      conversion_arguments cvar
    end
  end

  # Implements argument processing for error handling arguments. These
  # arguments are not part of the introspected signature, but their
  # presence is indicated by the 'throws' attribute of the function.
  class ErrorArgument < Argument::Base
    def pre
      [ "#{callarg} = FFI::MemoryPointer.new(:pointer).write_pointer nil" ]
    end

    def post
      [ "GirFFI::ArgHelper.check_error(#{callarg})" ]
    end
  end

  # Argument builder that does nothing. Implements Null Object pattern.
  class NullArgument
    def initialize *args; end
    def pre; []; end
    def post; []; end
    def callarg; end
  end
end
