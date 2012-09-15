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
      builder_for var_gen, arginfo.name, type, libmodule
    end

    def self.builder_for var_gen, name, type, libmodule
      klass = case type.tag
              when :interface
                case type.interface.info_type
                when :callback
                  return CallbackInArgument.new var_gen, name, type, libmodule
                else
                  RegularInArgument
                end
              when :array
                if type.array_type == :c
                  CArrayInArgument
                else
                  RegularInArgument
                end
              else
                RegularInArgument
              end
      return klass.new var_gen, name, type
    end
  end

  # Implements argument processing for callback arguments with direction
  # :in.
  class CallbackInArgument < Argument::InBase
    def initialize var_gen, name, type, libmodule
      super var_gen, name, type
      @libmodule = libmodule
    end

    def pre
      iface = type_info.interface
      [ "#{callarg} = GirFFI::CallbackHelper.wrap_in_callback_args_mapper \"#{iface.namespace}\", \"#{iface.name}\", #{@name}",
        "#{@libmodule}::CALLBACKS << #{callarg}" ]
    end
  end

  # Implements argument processing for array arguments with direction :in.
  class CArrayInArgument < Argument::InBase
    def pre
      pr = []
      size = type_info.array_fixed_size
      if size > -1
        pr << "GirFFI::ArgHelper.check_fixed_array_size #{size}, #{@name}, \"#{@name}\""
      end
      pr << "#{callarg} = GirFFI::InPointer.from_array #{elm_t}, #{@name}"
      pr
    end
  end

  # Implements argument processing for arguments with direction :in whose
  # type-specific processing is left to FFI (e.g., ints and floats, and
  # objects that implement to_ptr.).
  #
  # Implements argument processing for arguments with direction :in that
  # are GObjects.
  #
  # Implements argument processing for UTF8 string arguments with direction
  # :in.
  #
  # Implements argument processing for void pointer arguments with
  # direction :in.
  class RegularInArgument < Argument::InBase
    def pre
      pr = []
      assign_array_length(pr)
      set_function_call_argument(pr)
      pr
    end

    def assign_array_length(pr)
      if @array_arg
        arrname = @array_arg.name
        pr << "#{@name} = #{arrname}.nil? ? 0 : #{arrname}.length"
      end
    end

    def set_function_call_argument(pr)
      if type_tag == :interface && [:object, :struct].include?(type_info.interface.info_type)
        pr << "#{callarg} = #{argument_class_name}.from #{@name}"
      elsif [:utf8, :void].include? type_tag
        pr << "#{callarg} = #{argument_class_name}.from #{type_tag.inspect}, #{@name}"
      elsif [:glist, :gslist, :ghash].include? type_tag
        pr << "#{callarg} = #{argument_class_name}.from #{elm_t}, #{@name}"
      else
        pr << "#{callarg} = #{@name}"
      end
    end
  end

  # Implements argument processing for arguments with direction :out.
  module OutArgument
    def self.build var_gen, arginfo, libmodule
      type = arginfo.argument_type
      klass = case type.tag
              when :interface
                case type.interface.info_type
                when :enum, :flags
                  EnumOutArgument
                else
                  if arginfo.caller_allocates?
                    AllocatedInterfaceOutArgument
                  else
                    InterfaceOutArgument
                  end
                end
              when :array
                if type.zero_terminated?
                  InterfaceOutArgument
                else
                  case type.array_type
                  when :c
                    CArrayOutArgument
                  when :array
                    it = PointerLikeOutArgument.new var_gen, arginfo.name, type
                    it.extend WithTypedContainerPostMethod
                    return it
                  end
                end
              when :glist, :gslist
                it = PointerLikeOutArgument.new var_gen, arginfo.name, type
                it.extend WithTypedContainerPostMethod
                return it
              when :ghash
                it = PointerLikeOutArgument.new var_gen, arginfo.name, type
                it.extend WithTypedContainerPostMethod
                return it
              else
                RegularOutArgument
              end
      klass.new var_gen, arginfo.name, type
    end
  end

  # Implements argument processing for arguments with direction
  # :out that are neither arrays nor 'interfaces'.
  class RegularOutArgument < Argument::OutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.for #{type_tag.inspect}" ]
    end

    def post
      [ "#{retname} = #{callarg}.to_value" ]
    end
  end

  # Implements argument processing for arguments with direction
  # :out that are enums
  class EnumOutArgument < Argument::OutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.for :gint32" ]
    end

    def post
      [ "#{retname} = #{argument_class_name}[#{callarg}.to_value]" ]
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

  # Implements argument processing for interface arguments with direction
  # :out (structs, objects, etc.).
  #
  # Implements argument processing for strv arguments with direction
  # :out.
  class InterfaceOutArgument < PointerLikeOutArgument
    def post
      [ "#{retname} = #{argument_class_name}.wrap #{callarg}.to_value" ]
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
      klass = case type.tag
              when :interface
                case type.interface.info_type
                when :enum, :flags
                  EnumInOutArgument
                else
                  InterfaceInOutArgument
                end
              when :array
                if type.zero_terminated?
                  StrvInOutArgument
                else
                  case type.array_type
                  when :c
                    CArrayInOutArgument
                  when :array
                    it = Argument::InOutBase.new var_gen, arginfo.name, type
                    it.extend WithTypedContainerInOutPreMethod
                    it.extend WithTypedContainerPostMethod
                    return it
                  end
                end
              when :glist, :gslist
                it = Argument::InOutBase.new var_gen, arginfo.name, type
                it.extend WithTypedContainerInOutPreMethod
                it.extend WithTypedContainerPostMethod
                return it
              when :ghash
                it = Argument::InOutBase.new var_gen, arginfo.name, type
                it.extend WithTypedContainerInOutPreMethod
                it.extend WithTypedContainerPostMethod
                return it
              else
                RegularInOutArgument
              end

      klass.new var_gen, arginfo.name, type
    end
  end

  # Implements argument processing for arguments with direction
  # :inout that are enums.
  class EnumInOutArgument < Argument::InOutBase
    def pre
      pr = []
      pr << "#{callarg} = GirFFI::InOutPointer.from :gint32, #{argument_class_name}[#{@name}]"
      pr
    end

    def post
      [ "#{retname} = #{argument_class_name}[#{callarg}.to_value]" ]
    end
  end

  # Implements argument processing for interface arguments with direction
  # :inout (structs, objects, etc.).
  class InterfaceInOutArgument < Argument::InOutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from :pointer, #{argument_class_name}.from(#{@name}).to_ptr" ]
    end

    def post
      [ "#{retname} = #{argument_class_name}.wrap(#{callarg}.to_value)" ]
    end
  end

  # Implements argument processing for strv arguments with direction
  # :inout.
  class StrvInOutArgument < Argument::InOutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from_array #{elm_t}, #{@name}" ]
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

  module WithTypedContainerInOutPreMethod
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from :pointer, #{argument_class_name}.from(#{elm_t}, #{@name})" ]
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
                  arginfo.constructor?)
    end

    def self.builder_for var_gen, name, type, is_constructor
      if type.tag == :interface and
        [:interface, :object].include? type.interface.info_type
        klass = if is_constructor
                  ConstructorReturnValue
                else
                  ObjectReturnValue
                end
        klass.new var_gen, name, type
      else
        builder_for_field_getter var_gen, name, type
      end
    end

    def self.builder_for_field_getter var_gen, name, type
      klass = case type.tag
              when :void
                if type.pointer?
                  RegularReturnValue
                else
                  VoidReturnValue
                end
              when :interface
                case type.interface.info_type
                when :struct, :union, :interface, :object
                  InterfaceReturnValue
                else
                  RegularReturnValue
                end
              when :array
                if type.zero_terminated?
                  StrvReturnValue
                else
                  case type.array_type
                  when :c
                    CArrayReturnValue
                  when :array
                    it = ReturnValue.new var_gen, name, type
                    it.extend WithTypedContainerPostMethod
                    return it
                  when :byte_array
                    ByteArrayReturnValue
                  else
                    PtrArrayReturnValue
                  end
                end
              when :glist, :gslist
                it = ReturnValue.new var_gen, name, type
                it.extend WithTypedContainerPostMethod
                return it
              when :ghash
                it = ReturnValue.new var_gen, name, type
                it.extend WithTypedContainerPostMethod
                return it
              when :utf8
                Utf8ReturnValue
              else
                RegularReturnValue
              end
      klass.new var_gen, name, type
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
  class InterfaceReturnValue < ReturnValue
    def post
      [ "#{retname} = #{argument_class_name}.wrap(#{cvar})" ]
    end
  end

  # Implements argument processing for object return values.
  class ObjectReturnValue < ReturnValue
    def post
      [ "#{retname} = GirFFI::ArgHelper.object_pointer_to_object(#{cvar})" ]
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

  # Implements argument processing for NULL-terminated string array return values.
  class StrvReturnValue < ReturnValue
    def post
      [ "#{retname} = GLib::Strv.wrap(#{cvar})" ]
    end
  end

  # Implements argument processing for UTF8 string return values.
  class Utf8ReturnValue < ReturnValue
    def post
      [ "#{retname} = GirFFI::ArgHelper.ptr_to_utf8 #{cvar}" ]
    end
  end

  # Implements argument processing for GByteArray return values.
  class ByteArrayReturnValue < ReturnValue
    def post
      [ "#{retname} = GLib::ByteArray.wrap(#{cvar})" ]
    end
  end

  # Implements argument processing for GPtrArray return values.
  class PtrArrayReturnValue < ReturnValue
    def post
      [ "#{retname} = GLib::PtrArray.wrap(#{cvar})" ]
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
