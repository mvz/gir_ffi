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

  module InArgument
    def self.build var_gen, arginfo, libmodule
      type = arginfo.argument_type
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
              when :glist
                ListInArgument
              when :gslist
                SListInArgument
              when :ghash
                HashTableInArgument
              when :utf8
                Utf8InArgument
              else
                RegularInArgument
              end
      klass.new var_gen, arginfo.name, arginfo, libmodule
    end
  end

  # Implements argument processing for callback arguments with direction
  # :in.
  class CallbackInArgument < Argument::InBase
    def pre
      iface = type_info.interface
      [ "#{callarg} = GirFFI::CallbackHelper.wrap_in_callback_args_mapper \"#{iface.namespace}\", \"#{iface.name}\", #{@name}",
        "::#{@libmodule}::CALLBACKS << #{callarg}" ]
    end
  end

  # Implements argument processing for void pointer arguments with
  # direction :in.
  class VoidInArgument < Argument::InBase
    def pre
      [ "#{callarg} = GirFFI::ArgHelper.object_to_inptr #{@name}" ]
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
      pr << "#{callarg} = GirFFI::InPointer.from_array #{subtype_tag.inspect}, #{@name}"
      pr
    end
  end

  # Implements argument processing for glist arguments with
  # direction :in.
  class ListInArgument < Argument::InBase
    def pre
      [ "#{callarg} = GLib::List.from_array #{subtype_tag.inspect}, #{@name}" ]
    end
  end

  # Implements argument processing for gslist arguments with direction :in.
  class SListInArgument < Argument::InBase
    def pre
      [ "#{callarg} = GLib::SList.from_array #{subtype_tag.inspect}, #{@name}" ]
    end
  end

  # Implements argument processing for ghash arguments with direction :in.
  class HashTableInArgument < Argument::InBase
    def pre
      [ "#{callarg} = GLib::HashTable.from_hash #{subtype_tag(0).inspect}, #{subtype_tag(1).inspect}, #{@name}" ]
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
    def self.build var_gen, arginfo, libmodule
      type = arginfo.argument_type
      klass = case type.tag
              when :interface
                case type.interface.info_type
                when :enum, :flags
                  EnumOutArgument
                else
                  InterfaceOutArgument
                end
              when :array
                if type.zero_terminated?
                  StrvOutArgument
                else
                  case type.array_type
                  when :c
                    CArrayOutArgument
                  when :array
                    ArrayOutArgument
                  end
                end
              when :glist
                ListOutArgument
              when :gslist
                SListOutArgument
              when :ghash
                HashTableOutArgument
              else
                RegularOutArgument
              end
      klass.new var_gen, arginfo.name, arginfo, libmodule
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
  # :out (structs, objects, etc.).
  class InterfaceOutArgument < Argument::OutBase
    def pre
      if @arginfo.caller_allocates?
	[ "#{callarg} = #{argument_class_name}.allocate" ]
      else
	[ "#{callarg} = GirFFI::InOutPointer.for :pointer" ]
      end
    end

    def post
      if @arginfo.caller_allocates?
	[ "#{retname} = #{callarg}" ]
      else
	[ "#{retname} = #{argument_class_name}.wrap #{callarg}.to_value" ]
      end
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
    def postpost
      tag = subtype_tag

      args = [callarg, array_size]
      if tag == :interface or tag == :interface_pointer
        args.unshift subtype_class_name
      end

      [ "#{retname} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{args.join ', '}" ]
    end
  end

  # Implements argument processing for strv arguments with direction
  # :out.
  class StrvOutArgument < PointerLikeOutArgument
    def post
      [ "#{retname} = GirFFI::ArgHelper.outptr_strv_to_utf8_array #{callarg}" ]
    end
  end

  # Implements argument processing for GArray arguments with direction
  # :out.
  class ArrayOutArgument < PointerLikeOutArgument
    include Argument::ListBase

    def post
      pp = []
      pp << "#{retname} = GLib::Array.wrap #{callarg}.to_value"
      pp << "#{retname}.element_type = #{elm_t}"
      pp
    end
  end

  # Implements argument processing for glist arguments with direction
  # :out.
  class ListOutArgument < PointerLikeOutArgument
    include Argument::ListBase

    def post
      [ "#{retname} = GLib::List.wrap #{elm_t}, #{callarg}.to_value" ]
    end
  end

  # Implements argument processing for gslist arguments with direction
  # :out.
  class SListOutArgument < PointerLikeOutArgument
    include Argument::ListBase

    def post
      [ "#{retname} = GLib::SList.wrap #{elm_t}, #{callarg}.to_value" ]
    end
  end

  # Implements argument processing for ghash arguments with direction
  # :out.
  class HashTableOutArgument < PointerLikeOutArgument
    include Argument::HashTableBase

    def post
      [ "#{retname} = GLib::HashTable.wrap #{key_t}, #{val_t}, #{callarg}.to_value" ]
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
                    ArrayInOutArgument
                  end
                end
              when :glist
                ListInOutArgument
              when :gslist
                SListInOutArgument
              when :ghash
                HashTableInOutArgument
              else
                RegularInOutArgument
              end

      klass.new var_gen, arginfo.name, arginfo, libmodule
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
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from_array #{subtype_tag.inspect}, #{@name}" ]
    end

    def post
      [ "#{retname} = GirFFI::ArgHelper.outptr_strv_to_utf8_array #{callarg}" ]
    end
  end

  # Implements argument processing for array arguments with direction
  # :inout.
  class CArrayInOutArgument < Argument::InOutBase
    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from_array #{subtype_tag.inspect}, #{@name}" ]
    end

    def postpost
      tag = subtype_tag
      size = array_size
      pst = [ "#{retname} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{callarg}, #{size}" ]
      pst
    end

  end

  # Implements argument processing for GArray arguments with direction
  # :inout.
  class ArrayInOutArgument < Argument::InOutBase
    include Argument::ListBase

    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from :pointer, #{@name}" ]
    end

    def post
      pp = []
      pp << "#{retname} = GLib::Array.wrap(#{callarg}.to_value)"
      pp << "#{retname}.element_type = #{elm_t}"
      pp
    end
  end

  # Implements argument processing for glist arguments with direction
  # :inout.
  class ListInOutArgument < Argument::InOutBase
    include Argument::ListBase

    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from :pointer, GLib::List.from_array(#{subtype_tag.inspect}, #{@name})" ]
    end

    def post
      [ "#{retname} = GLib::List.wrap #{elm_t}, #{callarg}.to_value" ]
    end
  end

  # Implements argument processing for gslist arguments with direction
  # :inout.
  class SListInOutArgument < Argument::InOutBase
    include Argument::ListBase

    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from :pointer, GLib::SList.from_array(#{subtype_tag.inspect}, #{@name})" ]
    end

    def post
      [ "#{retname} = GLib::SList.wrap #{elm_t}, #{callarg}.to_value" ]
    end
  end

  # Implements argument processing for ghash arguments with direction
  # :inout.
  class HashTableInOutArgument < Argument::InOutBase
    include Argument::HashTableBase

    def pre
      [ "#{callarg} = GirFFI::InOutPointer.from :pointer, GLib::HashTable.from_hash(#{key_t}, #{val_t}, #{@name})" ]
    end

    def post
      [ "#{retname} = GLib::HashTable.wrap #{key_t}, #{val_t}, #{callarg}.to_value" ]
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

  # Implements argument processing for return values.
  class ReturnValue < Argument::Base
    def cvar
      @cvar ||= @var_gen.new_var
    end

    def retname
      @retname ||= @var_gen.new_var
    end

    def type_info
      @arginfo.return_type
    end

    def self.build var_gen, arginfo
      klass = builder_for(arginfo.return_type,
                                       arginfo.constructor?)
      klass.new var_gen, arginfo.name, arginfo, nil
    end

    def self.builder_for type, is_constructor
      case type.tag
      when :void
        if type.pointer?
          RegularReturnValue
        else
          VoidReturnValue
        end
      when :interface
        case type.interface.info_type
        when :struct, :union
          InterfaceReturnValue
        when :interface, :object
          if is_constructor
            ConstructorReturnValue
          else
            ObjectReturnValue
          end
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
      when :glist
        ListReturnValue
      when :gslist
        SListReturnValue
      when :ghash
        HashTableReturnValue
      else
        RegularReturnValue
      end
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

  # Implements argument processing for GList return values.
  class ListReturnValue < ReturnValue
    include Argument::ListBase

    def post
      [ "#{retname} = GLib::List.wrap(#{elm_t}, #{cvar})" ]
    end
  end

  # Implements argument processing for GSList return values.
  class SListReturnValue < ReturnValue
    include Argument::ListBase

    def post
      [ "#{retname} = GLib::SList.wrap(#{elm_t}, #{cvar})" ]
    end
  end

  # Implements argument processing for GHashTable return values.
  class HashTableReturnValue < ReturnValue
    include Argument::HashTableBase

    def post
      [ "#{retname} = GLib::HashTable.wrap(#{key_t}, #{val_t}, #{cvar})" ]
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
      [ "#{retname} = GLib::Array.wrap(#{cvar})",
        "#{retname}.element_type = #{elm_t}" ]
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
      if RUBY_VERSION < "1.9"
        @cvar
      else
        if type_tag == :utf8
          "#{cvar}.force_encoding('utf-8')"
        else
          @cvar
        end
      end
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
