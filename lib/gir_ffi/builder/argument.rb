require 'forwardable'

require 'gir_ffi/in_pointer'
require 'gir_ffi/in_out_pointer'

require 'gir_ffi/builder/argument/base'
require 'gir_ffi/builder/argument/in_base'
require 'gir_ffi/builder/argument/out_base'
require 'gir_ffi/builder/argument/in_out_base'

module GirFFI::Builder
  module Argument
    def self.build var_gen, arginfo, libmodule
      {
        :inout => InOutArgument,
        :in => InArgument,
        :out => OutArgument
      }[arginfo.direction].build var_gen, arginfo, libmodule
    end
  end

  module InArgument
    def self.build var_gen, arginfo, libmodule
      type = arginfo.argument_type
      builder_for var_gen, arginfo.name, type, arginfo.direction, libmodule
    end

    def self.builder_for var_gen, name, type, direction, libmodule
      case type.flattened_tag
      when :callback
        return CallbackInArgument.new var_gen, name, type, libmodule
      else
        return RegularArgument.new var_gen, name, type, direction
      end
    end
  end

  # Implements argument processing for callback arguments with direction
  # :in.
  class CallbackInArgument < Argument::InBase
    def initialize var_gen, name, type, libmodule
      super var_gen, name, type, :in
      @libmodule = libmodule
    end

    def pre
      iface = type_info.interface
      [ "#{callarg} = GirFFI::CallbackHelper.wrap_in_callback_args_mapper \"#{iface.namespace}\", \"#{iface.name}\", #{@name}",
        "#{@libmodule}::CALLBACKS << #{callarg}" ]
    end
  end

  # Implements argument processing for arguments not handled by more specific
  # builders.
  class RegularArgument < Argument::Base
    def initialize var_gen, name, typeinfo, direction
      super var_gen, name, typeinfo, direction
      @direction = direction
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
        value = case @direction
                when :inout
                  case specialized_type_tag
                  when :enum, :flags
                    "#{argument_class_name}[#{callarg}.to_value]"
                  else
                    "#{argument_class_name}.wrap(#{output_conversion_arguments})"
                  end
                when :out
                  case specialized_type_tag
                  when :enum, :flags
                    "#{argument_class_name}[#{callarg}.to_value]"
                  when :strv, :object, :struct
                    "#{argument_class_name}.wrap(#{callarg}.to_value)"
                  else
                    "#{callarg}.to_value"
                  end
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
      if type_tag == :array
        size = type_info.array_fixed_size
        if size > -1
          true
        end
      end
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
      value = case @direction
              when :out
                "GirFFI::InOutPointer.for #{specialized_type_tag.inspect}"
              when :in
                if needs_ingoing_parameter_conversion?
                  parameter_conversion
                else
                  @name
                end
              when :inout
                parameter_conversion
              end
      "#{callarg} = #{value}"
    end

    def needs_outgoing_parameter_conversion?
      case specialized_type_tag
      when :object, :struct, :utf8, :void, :glist, :gslist, :ghash, :array, :c,
        :zero_terminated, :strv
        true
      else
        false
      end
    end

    def needs_ingoing_parameter_conversion?
      case specialized_type_tag
      when :object, :struct, :utf8, :void, :glist, :gslist, :ghash, :array, :c,
        :zero_terminated, :strv
        true
      else
        false
      end
    end

    def parameter_conversion
      case specialized_type_tag
      when :enum, :flags
        base = "#{argument_class_name}[#{parameter_conversion_arguments}]"
        "GirFFI::InOutPointer.from #{specialized_type_tag.inspect}, #{base}"
      else
        base = "#{argument_class_name}.from(#{parameter_conversion_arguments})"
        if has_output_value?
          "GirFFI::InOutPointer.from :pointer, #{base}"
        else
          base
        end
      end
    end

    def output_conversion_arguments
      conversion_arguments "#{callarg}.to_value"
    end

    def parameter_conversion_arguments
      conversion_arguments @name
    end

    def conversion_arguments name
      case specialized_type_tag
      when :utf8, :void
        "#{self_t}, #{name}"
      when :glist, :gslist, :ghash, :array
        "#{elm_t}, #{name}"
      when :c, :zero_terminated
        "#{type_specification}, #{name}"
      when :strv
        "#{name}"
      else
        "#{name}"
      end
    end

    def self_t
      type_tag.inspect
    end
  end

  # Implements argument processing for arguments with direction :out.
  module OutArgument
    def self.build var_gen, arginfo, libmodule
      type = arginfo.argument_type
      direction = arginfo.direction
      klass = case type.flattened_tag
              when :object, :struct
                if arginfo.caller_allocates?
                  AllocatedInterfaceOutArgument
                else
                  RegularArgument
                end
              when :c
                CArrayOutArgument
              when :array, :glist, :gslist, :ghash
                it = PointerLikeOutArgument.new var_gen, arginfo.name, type, direction
                it.extend WithTypedContainerPostMethod
                return it
              else
                RegularArgument
              end
      klass.new var_gen, arginfo.name, type, direction
    end
  end

  # Implements argument processing for interface arguments with direction
  # :out (structs, objects, etc.), allocated by the caller.
  class AllocatedInterfaceOutArgument < Argument::OutBase
    def pre
      [ "#{callarg} = #{argument_class_name}.allocate" ]
    end

    def post
      [ "#{retname} = #{callarg}" ]
    end
  end

  # Implements argument processing for array arguments with direction
  # :out.
  class CArrayOutArgument < Argument::OutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.for_array #{subtype_tag_or_class_name}" ]
    end

    def postpost
      [ "#{retname} = #{callarg}.to_sized_array_value #{array_size}" ]
    end
  end

  # Base class for arguments with direction :out for which the base type is
  # a pointer: For these, a pointer to a pointer needs to be passed to the
  # C function.
  class PointerLikeOutArgument < Argument::OutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.for :pointer" ]
    end
  end

  module WithTypedContainerPostMethod
    def post
      [ "#{retname} = #{argument_class_name}.wrap #{elm_t}, #{callarg}.to_value" ]
    end
  end

  # Implements argument processing for arguments with direction :inout.
  module InOutArgument
    def self.build var_gen, arginfo, libmodule
      type = arginfo.argument_type
      direction = arginfo.direction
      klass = case type.flattened_tag
              when :c
                CArrayInOutArgument
              when :strv
                StrvInOutArgument
              when :enum, :flags, :object, :struct, :array,
                :glist, :gslist, :ghash
                RegularArgument
              else
                RegularInOutArgument
              end

      klass.new var_gen, arginfo.name, type, direction
    end
  end

  # Implements argument processing for strv arguments with direction
  # :inout.
  class StrvInOutArgument < Argument::InOutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from #{type_specification}, #{@name}" ]
    end

    def post
      [ "#{retname} = GLib::Strv.wrap(#{callarg}.to_value)" ]
    end
  end

  # Implements argument processing for array arguments with direction
  # :inout.
  class CArrayInOutArgument < Argument::InOutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from_array #{elm_t}, #{@name}" ]
    end

    def postpost
      size = array_size
      pst = [ "#{retname} = #{callarg}.to_sized_array_value #{size}" ]
      pst
    end
  end

  # Implements argument processing for arguments with direction
  # :inout that are neither arrays nor 'interfaces'.
  class RegularInOutArgument < Argument::InOutBase
    def pre
      pr = []
      if @array_arg
        pr << "#{@name} = #{@array_arg.name}.length"
      end
      pr << "#{callarg} = GirFFI::InOutPointer.from #{type_tag.inspect}, #{@name}"
      pr
    end

    def post
      [ "#{retname} = #{callarg}.to_value" ]
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
                  WrappingReturnValue
                end
        klass.new var_gen, name, type, direction
      else
        builder_for_field_getter var_gen, name, type, direction
      end
    end

    def self.builder_for_field_getter var_gen, name, type, direction
      klass = case type.flattened_tag
              when :void
                if type.pointer?
                  RegularReturnValue
                else
                  VoidReturnValue
                end
              when :struct, :union, :interface, :object, :strv,
                :zero_terminated, :byte_array, :ptr_array
                WrappingReturnValue
              when :c
                CArrayReturnValue
              when :array, :glist, :gslist, :ghash
                it = ReturnValue.new var_gen, name, type, direction
                it.extend WithTypedContainerPostMethod
                return it
              when :utf8
                Utf8ReturnValue
              else
                RegularReturnValue
              end
      klass.new var_gen, name, type, direction
    end
  end

  # Implements argument processing for return values.
  class ReturnValue < Argument::Base
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

  # Null object to represent the case where no actual value is returned.
  class VoidReturnValue < ReturnValue
    def cvar; end
    def retname; end
  end

  # Implements argument processing for interface return values (interfaces
  # and structs, but not objects, which need special handling for
  # polymorphism and constructors).
  #
  # Implements argument processing for object return values when the method is
  # not a constructor.
  #
  # Implements argument processing for NULL-terminated string array return values.
  #
  # Implements argument processing for GByteArray return values.
  #
  # Implements argument processing for GPtrArray return values.
  class WrappingReturnValue < ReturnValue
    def post
      [ "#{retname} = #{argument_class_name}.wrap(#{cvar})" ]
    end
  end

  # Implements argument processing for object constructors.
  class ConstructorReturnValue < ReturnValue
    def post
      [ "#{retname} = self.constructor_wrap(#{cvar})" ]
    end
  end

  # Implements argument processing for array return values.
  class CArrayReturnValue < ReturnValue
    def post
      size = array_size

      [ "#{retname} = GirFFI::ArgHelper.ptr_to_typed_array #{subtype_tag_or_class_name}, #{cvar}, #{size}" ]
    end
  end

  # Implements argument processing for UTF8 string return values.
  class Utf8ReturnValue < ReturnValue
    def post
      [ "#{retname} = GirFFI::ArgHelper.ptr_to_utf8 #{cvar}" ]
    end
  end

  # Implements argument processing for other return values.
  class RegularReturnValue < ReturnValue
    def retval
      @callarg
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
