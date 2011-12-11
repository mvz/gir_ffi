require 'forwardable'

require 'gir_ffi/in_pointer'
require 'gir_ffi/in_out_pointer'

require 'gir_ffi/builder/argument/base'
require 'gir_ffi/builder/argument/in_base'
require 'gir_ffi/builder/argument/out_base'
require 'gir_ffi/builder/argument/in_out_base'
require 'gir_ffi/builder/argument/list_base'
require 'gir_ffi/builder/argument/hash_table_base'

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

  module ArgumentFactoryHelpers
    def provider_for type
      case type.tag
      when :glist, :gslist, :array
        ListTypesProvider.new(type)
      when :ghash
        HashTableTypesProvider.new(type)
      else
        nil
      end
    end
  end

  module InArgument
    extend ArgumentFactoryHelpers

    def self.build var_gen, arginfo, libmodule
      type = arginfo.argument_type
      builder_for var_gen, arginfo.name, type, libmodule
    end

    def self.builder_for var_gen, name, type, libmodule
      klass = case type.tag
              when :interface
                if type.interface.info_type == :callback
                  CallbackInArgument
                else
                  RegularInArgument
                end
              when :void
                VoidInArgument
              when :array
                if type.array_type == :c
                  CArrayInArgument
                else
                  RegularInArgument
                end
              when :glist, :gslist, :ghash
                provider = provider_for type
                return ListInArgument.new var_gen, name, type, libmodule, provider
              when :utf8
                Utf8InArgument
              else
                RegularInArgument
              end
      return klass.new var_gen, name, type, libmodule
    end
  end

  # Implements argument processing for callback arguments with direction
  # :in.
  class CallbackInArgument < Argument::InBase
    def pre
      iface = type_info.interface
      [ "#{callarg} = GirFFI::CallbackHelper.wrap_in_callback_args_mapper \"#{iface.namespace}\", \"#{iface.name}\", #{@name}",
        "#{@libmodule}::CALLBACKS << #{callarg}" ]
    end
  end

  # Implements argument processing for void pointer arguments with
  # direction :in.
  class VoidInArgument < Argument::InBase
    def pre
      [ "#{callarg} = GirFFI::ArgHelper.object_to_inptr #{@name}" ]
    end
  end

  class TypesProviderBase
    def initialize type
      @type = type
    end

    TAG_TO_CONTAINER_CLASS_MAP = {
      :glist => 'GLib::List',
      :gslist => 'GLib::SList',
      :ghash => 'GLib::HashTable',
      :array => 'GLib::Array'
    }

    def class_name
      TAG_TO_CONTAINER_CLASS_MAP[@type.tag]
    end

    def subtype_tag index=0
      st = @type.param_type(index)
      t = st.tag
      case t
      when :GType
        return :gtype
      when :interface
        return :interface_pointer if st.pointer?
        return :interface
      when :void
        return :gpointer if st.pointer?
        return :void
      else
        return t
      end
    end
  end

  class ListTypesProvider < TypesProviderBase
    def elm_t
      subtype_tag.inspect
    end
  end

  class HashTableTypesProvider < TypesProviderBase
    def elm_t
      [subtype_tag(0), subtype_tag(1)].inspect
    end
  end

  # Implements argument processing for array arguments with direction :in.
  class CArrayInArgument < Argument::InBase
    include Argument::ListBase
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

  # Implements argument processing for glist, gslist and ghash arguments
  # with direction :in.
  class ListInArgument < Argument::InBase
    extend Forwardable
    def_delegators :@elm_t_provider, :elm_t, :class_name

    def initialize var_gen, name, typeinfo, libmodule, provider
      super var_gen, name, typeinfo, libmodule
      @elm_t_provider = provider
    end

    def pre
      [ "#{callarg} = #{class_name}.from #{elm_t}, #{@name}" ]
    end
  end

  # Implements argument processing for UTF8 string arguments with direction
  # :in.
  class Utf8InArgument < Argument::InBase
    def pre
      [ "#{callarg} = GirFFI::InPointer.from :utf8, #{@name}" ]
    end
  end

  # Implements argument processing for arguments with direction :in whose
  # type-specific processing is left to FFI (e.g., ints and floats, and
  # objects that implement to_ptr.).
  class RegularInArgument < Argument::InBase
    def pre
      pr = []
      if @array_arg
        arrname = @array_arg.name
	pr << "#{@name} = #{arrname}.nil? ? 0 : #{arrname}.length"
      end
      pr << "#{callarg} = #{@name}"
      pr
    end
  end

  # Implements argument processing for arguments with direction :out.
  module OutArgument
    extend ArgumentFactoryHelpers

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
                  StrvOutArgument
                else
                  case type.array_type
                  when :c
                    CArrayOutArgument
                  when :array
                    provider = provider_for type
                    return ListOutArgument.new var_gen, arginfo.name, type, libmodule, provider
                  end
                end
              when :glist, :gslist, :ghash
                provider = provider_for type
                return ListOutArgument.new var_gen, arginfo.name, type, libmodule, provider
              else
                RegularOutArgument
              end
      klass.new var_gen, arginfo.name, type, libmodule
    end
  end

  # Implements argument processing for arguments with direction
  # :out that are neither arrays nor 'interfaces'.
  class RegularOutArgument < Argument::OutBase
    def post
      [ "#{retname} = #{callarg}.to_value" ]
    end

    private

    def base_type
      type_tag
    end
  end

  # Implements argument processing for arguments with direction
  # :out that are enums
  class EnumOutArgument < RegularOutArgument
    def post
      [ "#{retname} = #{argument_class_name}[#{callarg}.to_value]" ]
    end

    private

    def base_type
      :gint32
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

  # Implements argument processing for interface arguments with direction
  # :out (structs, objects, etc.).
  class InterfaceOutArgument < Argument::OutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.for :pointer" ]
    end

    def post
      [ "#{retname} = #{argument_class_name}.wrap #{callarg}.to_value" ]
    end
  end

  # Base class for arguments with direction :out for which the base type is
  # a pointer: For these, a pointer to a pointer needs to be passed to the
  # C function.
  class PointerLikeOutArgument < Argument::OutBase
    private

    def base_type
      :pointer
    end
  end

  # Implements argument processing for array arguments with direction
  # :out.
  class CArrayOutArgument < PointerLikeOutArgument
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.for_array #{subtype_tag_or_class_name}" ]
    end

    def postpost
      [ "#{retname} = #{callarg}.to_sized_array_value #{array_size}" ]
    end
  end

  # Implements argument processing for strv arguments with direction
  # :out.
  class StrvOutArgument < PointerLikeOutArgument
    def post
      [ "#{retname} = GirFFI::ArgHelper.outptr_strv_to_utf8_array #{callarg}" ]
    end
  end

  # Implements argument processing for glist arguments with direction
  # :out.
  class ListOutArgument < PointerLikeOutArgument
    extend Forwardable
    def_delegators :@elm_t_provider, :elm_t, :class_name

    def initialize var_gen, name, typeinfo, libmodule, provider
      super var_gen, name, typeinfo, libmodule
      @elm_t_provider = provider
    end

    def post
      [ "#{retname} = #{class_name}.wrap #{elm_t}, #{callarg}.to_value" ]
    end
  end

  # Implements argument processing for arguments with direction :inout.
  module InOutArgument
    extend ArgumentFactoryHelpers

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
                    provider = provider_for type
                    return ListInOutArgument.new var_gen, arginfo.name, type, libmodule, provider
                  end
                end
              when :glist, :gslist, :ghash
                provider = provider_for type
                return ListInOutArgument.new var_gen, arginfo.name, type, libmodule, provider
              else
                RegularInOutArgument
              end

      klass.new var_gen, arginfo.name, type, libmodule
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
      [ "#{callarg} = GirFFI::InOutPointer.from :pointer, #{@name}.to_ptr" ]
    end

    def post
      [ "#{retname} = #{argument_class_name}.wrap(#{callarg}.to_value)" ]
    end
  end

  # Implements argument processing for strv arguments with direction
  # :inout.
  class StrvInOutArgument < Argument::InOutBase
    include Argument::ListBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from_array #{elm_t}, #{@name}" ]
    end

    def post
      [ "#{retname} = GirFFI::ArgHelper.outptr_strv_to_utf8_array #{callarg}" ]
    end
  end

  # Implements argument processing for array arguments with direction
  # :inout.
  class CArrayInOutArgument < Argument::InOutBase
    include Argument::ListBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from_array #{elm_t}, #{@name}" ]
    end

    def postpost
      size = array_size
      pst = [ "#{retname} = #{callarg}.to_sized_array_value #{size}" ]
      pst
    end

  end

  # Implements argument processing for glist arguments with direction
  # :inout.
  class ListInOutArgument < Argument::InOutBase
    extend Forwardable
    def_delegators :@elm_t_provider, :elm_t, :class_name

    def initialize var_gen, name, typeinfo, libmodule, provider
      super var_gen, name, typeinfo, libmodule
      @elm_t_provider = provider
    end

    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from :pointer, #{class_name}.from(#{elm_t}, #{@name})" ]
    end

    def post
      [ "#{retname} = #{class_name}.wrap #{elm_t}, #{callarg}.to_value" ]
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
    extend ArgumentFactoryHelpers

    def self.build var_gen, arginfo
      type = arginfo.return_type
      klass = builder_for(var_gen, arginfo.name, type, arginfo.constructor?)
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
                    ArrayReturnValue
                  when :byte_array
                    ByteArrayReturnValue
                  else
                    PtrArrayReturnValue
                  end
                end
              when :glist, :gslist, :ghash
                provider = provider_for type
                return ListReturnValue.new var_gen, name, type, provider
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
    def initialize var_gen, name, type
      super var_gen, name, type, nil
    end

    def cvar
      @cvar ||= @var_gen.new_var
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

      [ "#{retname} = GirFFI::ArgHelper.ptr_to_#{subtype_tag}_array #{cvar}, #{size}" ]
    end
  end

  # Implements argument processing for NULL-terminated string array return values.
  class StrvReturnValue < ReturnValue
    def post
      [ "#{retname} = GirFFI::ArgHelper.strv_to_utf8_array #{cvar}" ]
    end
  end

  # Implements argument processing for UTF8 string return values.
  class Utf8ReturnValue < ReturnValue
    def post
      [ "#{retname} = GirFFI::ArgHelper.ptr_to_utf8 #{@cvar}" ]
    end
  end

  # Implements argument processing for GList return values.
  class ListReturnValue < ReturnValue
    extend Forwardable
    def_delegators :@elm_t_provider, :elm_t, :class_name

    def initialize var_gen, name, typeinfo, provider
      super var_gen, name, typeinfo
      @elm_t_provider = provider
    end

    def post
      [ "#{retname} = #{class_name}.wrap(#{elm_t}, #{cvar})" ]
    end
  end

  # Implements argument processing for GByteArray return values.
  class ByteArrayReturnValue < ReturnValue
    def post
      [ "#{retname} = GLib::ByteArray.wrap(#{cvar})" ]
    end
  end

  # Implements argument processing for GArray return values.
  class ArrayReturnValue < ReturnValue
    include Argument::ListBase

    def post
      [ "#{retname} = GLib::Array.wrap(#{elm_t}, #{cvar})" ]
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
      @cvar
    end
  end

  # Implements argument processing for error handling arguments. These
  # arguments are not part of the introspected signature, but their
  # presence is indicated by the 'throws' attribute of the function.
  class ErrorArgument < Argument::Base
    def callarg
      @callarg ||= @var_gen.new_var
    end

    def pre
      [ "#{callarg} = FFI::MemoryPointer.new(:pointer).write_pointer nil" ]
    end

    def post
      [ "GirFFI::ArgHelper.check_error(#{callarg})" ]
    end
  end

  # Argument builder that does nothing. Implements Null Object pattern.
  class NullArgument < Argument::Base
  end
end
