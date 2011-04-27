module GirFFI::Builder
  # Abstract parent class of the argument building classes. These classes
  # are used by Builder::Function to create the code that processes
  # each argument before and after the actual function call.
  class Argument
    KEYWORDS = [
      "alias", "and", "begin", "break", "case", "class", "def", "do",
      "else", "elsif", "end", "ensure", "false", "for", "if", "in",
      "module", "next", "nil", "not", "or", "redo", "rescue", "retry",
      "return", "self", "super", "then", "true", "undef", "unless",
      "until", "when", "while", "yield"
    ]

    attr_reader :callarg, :name, :retname

    attr_accessor :length_arg, :array_arg

    def initialize function_builder, arginfo=nil, libmodule=nil
      @arginfo = arginfo
      @inarg = nil
      @callarg = nil
      @retname = nil
      @name = nil
      @function_builder = function_builder
      @libmodule = libmodule
      @length_arg = nil
      @array_arg = nil
    end

    def self.build function_builder, arginfo, libmodule
      klass = case arginfo.direction
              when :inout
                InOutArgument
              when :in
                InArgument
              when :out
                OutArgument
              else
                raise ArgumentError
              end
      klass.build function_builder, arginfo, libmodule
    end

    def type_info
      @arginfo.argument_type
    end

    def type_tag
      type_info.tag
    end

    def subtype_tag index=0
      st = type_info.param_type(index)
      t = st.tag
      case t
      when :GType
        return :gtype
      when :interface
        return :interface_pointer if st.pointer?
        return :interface
      else
        return t
      end
    end

    def argument_class_name
      iface = type_info.interface
      "::#{iface.safe_namespace}::#{iface.name}"
    end

    def subtype_class_name index=0
      iface = type_info.param_type(index).interface
      "::#{iface.safe_namespace}::#{iface.name}"
    end

    def array_size
      if @length_arg
        @length_arg.retname
      else
        type_info.array_fixed_size
      end
    end

    def safe name
      if KEYWORDS.include? name
	"#{name}_"
      else
	name
      end
    end

    def inarg
      @array_arg.nil? ? @inarg : nil
    end

    def retval
      @array_arg.nil? ? @retname : nil
    end

    def pre
      []
    end

    def post
      []
    end

    def postpost
      []
    end
  end

  # Implements argument processing for arguments with direction :in.
  class InArgument < Argument
    def prepare
      @name = safe(@arginfo.name)
      @callarg = @function_builder.new_var
      @inarg = @name
    end

    def self.build function_builder, arginfo, libmodule
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
              when :glist, :gslist
                ListInArgument
              when :ghash
                HashTableInArgument
              when :utf8
                Utf8InArgument
              else
                RegularInArgument
              end
      klass.new function_builder, arginfo, libmodule
    end
  end

  # Implements argument processing for callback arguments with direction
  # :in.
  class CallbackInArgument < InArgument
    def pre
      iface = type_info.interface
      [ "#{@callarg} = GirFFI::ArgHelper.wrap_in_callback_args_mapper \"#{iface.namespace}\", \"#{iface.name}\", #{@name}",
        "::#{@libmodule}::CALLBACKS << #{@callarg}" ]
    end
  end

  # Implements argument processing for void pointer arguments with
  # direction :in.
  class VoidInArgument < InArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.object_to_inptr #{@name}" ]
    end
  end

  # Implements argument processing for array arguments with direction :in.
  class CArrayInArgument < InArgument
    def post
      unless @arginfo.ownership_transfer == :everything
        if subtype_tag == :utf8
          [ "GirFFI::ArgHelper.cleanup_ptr_ptr #{@callarg}" ]
        else
          [ "GirFFI::ArgHelper.cleanup_ptr #{@callarg}" ]
        end
      end
    end

    def pre
      pr = []
      size = type_info.array_fixed_size
      if size > -1
        pr << "GirFFI::ArgHelper.check_fixed_array_size #{size}, #{@name}, \"#{@name}\""
      end
      pr << "#{@callarg} = GirFFI::ArgHelper.#{subtype_tag}_array_to_inptr #{@name}"
      pr
    end
  end

  # Implements argument processing for glist and gslist arguments with
  # direction :in.
  class ListInArgument < InArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.#{subtype_tag}_array_to_#{type_tag} #{@name}" ]
    end
  end

  # Implements argument processing for ghash arguments with direction :in.
  class HashTableInArgument < InArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.hash_to_ghash #{subtype_tag(0).inspect}, #{subtype_tag(1).inspect}, #{@name}" ]
    end
  end

  # Implements argument processing for UTF8 string arguments with direction
  # :in.
  class Utf8InArgument < InArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.utf8_to_inptr #{@name}" ]
    end

    def post
      # TODO: Write tests and enable this.
      # [ "GirFFI::ArgHelper.cleanup_ptr #{@callarg}" ]
      []
    end
  end

  # Implements argument processing for arguments with direction :in whose
  # type-specific processing is left to FFI (e.g., ints and floats, and
  # objects that implement to_ptr.).
  class RegularInArgument < InArgument
    def pre
      pr = []
      if @array_arg
        arrname = @array_arg.name
	pr << "#{@name} = #{arrname}.nil? ? 0 : #{arrname}.length"
      end
      pr << "#{@callarg} = #{@name}"
      pr
    end
  end

  # Implements argument processing for arguments with direction :out.
  class OutArgument < Argument
    def prepare
      @name = safe(@arginfo.name)
      @callarg = @function_builder.new_var
      @retname = @function_builder.new_var
    end

    def self.build function_builder, arginfo, libmodule
      type = arginfo.argument_type
      klass = case arginfo.argument_type.tag
              when :interface
                case type.interface.info_type
                when :enum, :flags
                  EnumOutArgument
                else
                  InterfaceOutArgument
                end
              when :array
                if type.zero_terminated?
                  StrzOutArgument
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
      klass.new function_builder, arginfo, libmodule
    end
  end

  # Implements argument processing for arguments with direction
  # :out that are enums
  class EnumOutArgument < OutArgument
    def post
      pst = [ "#{@retname} = #{argument_class_name}[GirFFI::ArgHelper.outptr_to_int #{@callarg}]" ]
      if @arginfo.ownership_transfer == :everything
        pst << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
      end
      pst
    end

    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.int_outptr" ]
    end
  end

  # Implements argument processing for interface arguments with direction
  # :out (structs, objects, etc.).
  class InterfaceOutArgument < OutArgument
    def pre
      if @arginfo.caller_allocates?
	[ "#{@callarg} = #{argument_class_name}.allocate" ]
      else
	[ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
      end
    end

    def post
      if @arginfo.caller_allocates?
	[ "#{@retname} = #{@callarg}" ]
      else
	[ "#{@retname} = #{argument_class_name}.wrap GirFFI::ArgHelper.outptr_to_pointer(#{@callarg})" ]
      end
    end
  end

  # Implements argument processing for array arguments with direction
  # :out.
  class CArrayOutArgument < OutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
    end

    def postpost
      size = array_size
      tag = subtype_tag

      pp = []

      if tag == :interface or tag == :interface_pointer
        pp << "#{@retname} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{subtype_class_name}, #{@callarg}, #{size}"
      else
        pp << "#{@retname} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{@callarg}, #{size}"
      end

      if @arginfo.ownership_transfer == :everything
        case tag
        when :utf8
	  pp << "GirFFI::ArgHelper.cleanup_ptr_array_ptr #{@callarg}, #{size}"
        when :interface
	  pp << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
	else
	  pp << "GirFFI::ArgHelper.cleanup_ptr_ptr #{@callarg}"
	end
      end

      pp
    end
  end

  # Implements argument processing for strz arguments with direction
  # :out.
  class StrzOutArgument < OutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
    end

    def postpost
      [ "#{@retname} = GirFFI::ArgHelper.outptr_strz_to_utf8_array #{@callarg}" ]
    end
  end

  # Implements argument processing for GArray arguments with direction
  # :out.
  class ArrayOutArgument < OutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
    end

    def post
      tag = subtype_tag
      etype = GirFFI::Builder::TAG_TYPE_MAP[tag] || tag

      pp = []

      pp << "#{@retname} = GLib::Array.wrap(GirFFI::ArgHelper.outptr_to_pointer #{@callarg})"
      pp << "#{@retname}.element_type = #{etype.inspect}"

      if @arginfo.ownership_transfer == :everything
        pp << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
      end

      pp
    end
  end

  # Implements argument processing for glist arguments with direction
  # :out.
  # TODO: Pass list type into new List object.
  class ListOutArgument < OutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
    end

    def postpost
      [ "#{@retname} = GLib::List.wrap GirFFI::ArgHelper.outptr_to_pointer(#{@callarg})" ]
    end
  end

  # Implements argument processing for gslist arguments with direction
  # :out.
  # TODO: Pass list type into new SList object.
  class SListOutArgument < OutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
    end

    def postpost
      [ "#{@retname} = GLib::SList.wrap GirFFI::ArgHelper.outptr_to_pointer(#{@callarg})" ]
    end
  end

  # Implements argument processing for ghash arguments with direction
  # :out.
  class HashTableOutArgument < OutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
    end

    def postpost
      key_t = subtype_tag(0).inspect
      val_t = subtype_tag(1).inspect
      [ "#{@retname} = GLib::HashTable.wrap #{key_t}, #{val_t}, GirFFI::ArgHelper.outptr_to_pointer(#{@callarg})" ]
    end
  end

  # Implements argument processing for arguments with direction
  # :out that are neither arrays nor 'interfaces'.
  class RegularOutArgument < OutArgument
    def post
      pst = [ "#{@retname} = GirFFI::ArgHelper.outptr_to_#{type_tag} #{@callarg}" ]
      if @arginfo.ownership_transfer == :everything
        pst << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
      end
      pst
    end

    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.#{type_tag}_outptr" ]
    end
  end

  # Implements argument processing for arguments with direction :inout.
  class InOutArgument < Argument
    def prepare
      @name = safe(@arginfo.name)
      @callarg = @function_builder.new_var
      @inarg = @name
      @retname = @function_builder.new_var
    end

    def self.build function_builder, arginfo, libmodule
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
                case type.array_type
                when :c
                  CArrayInOutArgument
                when :array
                  ArrayInOutArgument
                end
              when :glist
                ListInOutArgument
              when :ghash
                HashTableInOutArgument
              else
                RegularInOutArgument
              end

      klass.new function_builder, arginfo, libmodule
    end
  end

  # Implements argument processing for arguments with direction
  # :inout that are enums.
  class EnumInOutArgument < InOutArgument
    def pre
      pr = []
      pr << "#{@callarg} = GirFFI::ArgHelper.int_to_inoutptr #{argument_class_name}[#{@name}]"
      pr
    end

    def post
      [ "#{@retname} = #{argument_class_name}[GirFFI::ArgHelper.outptr_to_int #{@callarg}]",
        "GirFFI::ArgHelper.cleanup_ptr #{@callarg}" ]
    end
  end

  # Implements argument processing for interface arguments with direction
  # :inout (structs, objects, etc.).
  class InterfaceInOutArgument < InOutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_to_inoutptr #{@name}.to_ptr" ]
    end

    def post
      [ "#{@retname} = #{argument_class_name}.wrap(GirFFI::ArgHelper.outptr_to_pointer #{@callarg})",
        "GirFFI::ArgHelper.cleanup_ptr #{@callarg}" ]
    end
  end

  # Implements argument processing for array arguments with direction
  # :inout.
  class CArrayInOutArgument < InOutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.#{subtype_tag}_array_to_inoutptr #{@name}" ]
    end

    def postpost
      tag = subtype_tag
      size = array_size
      pst = [ "#{@retname} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{@callarg}, #{size}" ]
      if @arginfo.ownership_transfer == :nothing
        pst << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
      else
        if tag == :utf8
          pst << "GirFFI::ArgHelper.cleanup_ptr_array_ptr #{@callarg}, #{size}"
        else
          pst << "GirFFI::ArgHelper.cleanup_ptr_ptr #{@callarg}"
        end
      end
      pst
    end
  end

  # Implements argument processing for GArray arguments with direction
  # :out.
  class ArrayInOutArgument < InOutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_to_inoutptr #{@name}" ]
    end

    def post
      tag = subtype_tag
      etype = GirFFI::Builder::TAG_TYPE_MAP[tag] || tag

      pp = []

      pp << "#{@retname} = GLib::Array.wrap(GirFFI::ArgHelper.outptr_to_pointer #{@callarg})"
      pp << "#{@retname}.element_type = #{etype.inspect}"
      pp << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"

      pp
    end
  end

  # Implements argument processing for glist arguments with direction
  # :inout.
  # TODO: Pass list type into new List object.
  class ListInOutArgument < InOutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_to_inoutptr(GirFFI::ArgHelper.#{subtype_tag}_array_to_#{type_tag} #{@name})" ]
    end

    def postpost
      pp = []
      pp << "#{@retname} = GLib::List.wrap GirFFI::ArgHelper.outptr_to_pointer(#{@callarg})"
      pp << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
      pp
    end
  end

  # Implements argument processing for ghash arguments with direction
  # :inout.
  class HashTableInOutArgument < InOutArgument
    def pre
      key_t = subtype_tag(0).inspect
      val_t = subtype_tag(1).inspect
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_to_inoutptr(GirFFI::ArgHelper.hash_to_ghash(#{key_t}, #{val_t}, #{@name}))" ]
    end

    def postpost
      pp = []

      key_t = subtype_tag(0).inspect
      val_t = subtype_tag(1).inspect
      pp << "#{@retname} = GLib::HashTable.wrap #{key_t}, #{val_t}, GirFFI::ArgHelper.outptr_to_pointer(#{@callarg})"
      pp << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
      pp
    end
  end

  # Implements argument processing for arguments with direction
  # :inout that are neither arrays nor 'interfaces'.
  class RegularInOutArgument < InOutArgument
    def pre
      pr = []
      if @array_arg
        pr << "#{@name} = #{@array_arg.name}.length"
      end
      pr << "#{@callarg} = GirFFI::ArgHelper.#{type_tag}_to_inoutptr #{@name}"
      pr
    end

    def post
      [ "#{@retname} = GirFFI::ArgHelper.outptr_to_#{type_tag} #{@callarg}",
        "GirFFI::ArgHelper.cleanup_ptr #{@callarg}" ]
    end
  end

  # Implements argument processing for return values.
  class ReturnValue < Argument
    attr_reader :cvar

    def prepare
      @cvar = @function_builder.new_var
      @retname = @function_builder.new_var
    end

    def type_info
      @arginfo.return_type
    end

    def self.build function_builder, arginfo
      type = arginfo.return_type
      klass = case type.tag
              when :void
                VoidReturnValue
              when :interface
                case type.interface.info_type
                when :interface, :struct
                  InterfaceReturnValue
                when :object
                  if arginfo.constructor?
                    ConstructorReturnValue
                  else
                    ObjectReturnValue
                  end
                else
                  RegularReturnValue
                end
              when :array
                if type.zero_terminated?
                  StrzReturnValue
                else
                  case type.array_type
                  when :c
                    CArrayReturnValue
                  when :array
                    ArrayReturnValue
                  when :byte_array
                    ByteArrayReturnValue
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
      klass.new function_builder, arginfo, nil
    end

    def inarg
      nil
    end
  end

  # Null object to represent the case where no actual values is returned.
  class VoidReturnValue < ReturnValue
    def prepare; end
  end

  # Implements argument processing for interface return values (interfaces
  # and structs, but not objects, which need special handling for
  # polymorphism and constructors.
  class InterfaceReturnValue < ReturnValue
    def post
      [ "#{@retname} = #{argument_class_name}.wrap(#{@cvar})" ]
    end
  end

  # Implements argument processing for object return values.
  class ObjectReturnValue < ReturnValue
    def post
      [ "#{@retname} = GirFFI::ArgHelper.object_pointer_to_object(#{@cvar})" ]
    end
  end

  # Implements argument processing for object constructors.
  class ConstructorReturnValue < ReturnValue
    def defining_class_name
      classinfo = @arginfo.container
      "::#{classinfo.namespace}::#{classinfo.name}"
    end

    def post
      [ "#{@retname} = self.constructor_wrap(#{@cvar})" ]
    end
  end

  # Implements argument processing for array return values.
  class CArrayReturnValue < ReturnValue
    def post
      size = array_size

      [ "#{@retname} = GirFFI::ArgHelper.ptr_to_#{subtype_tag}_array #{@cvar}, #{size}" ]
    end
  end

  # Implements argument processing for NULL-terminated string array return values.
  class StrzReturnValue < ReturnValue
    def post
      [ "#{@retname} = GirFFI::ArgHelper.strz_to_utf8_array #{@cvar}" ]
    end
  end

  # Implements argument processing for GList return values.
  class ListReturnValue < ReturnValue
    def post
      [ "#{@retname} = GLib::List.wrap(#{@cvar})" ]
    end
  end

  # Implements argument processing for GSList return values.
  class SListReturnValue < ReturnValue
    def post
      [ "#{@retname} = GLib::SList.wrap(#{@cvar})" ]
    end
  end

  # Implements argument processing for GHashTable return values.
  class HashTableReturnValue < ReturnValue
    def post
      key_t = subtype_tag(0).inspect
      val_t = subtype_tag(1).inspect
      [ "#{@retname} = GLib::HashTable.wrap(#{key_t}, #{val_t}, #{@cvar})" ]
    end
  end

  # Implements argument processing for GHashTable return values.
  class ByteArrayReturnValue < ReturnValue
    def post
      [ "#{@retname} = GLib::ByteArray.wrap(#{@cvar})" ]
    end
  end

  # Implements argument processing for GHashTable return values.
  class ArrayReturnValue < ReturnValue
    def post
      tag = subtype_tag
      etype = GirFFI::Builder::TAG_TYPE_MAP[tag] || tag
      [ "#{@retname} = GLib::Array.wrap(#{@cvar})",
        "#{@retname}.element_type = #{etype.inspect}" ]
    end
  end

  # Implements argument processing for other return values.
  class RegularReturnValue < ReturnValue
    def retval
      if RUBY_VERSION < "1.9"
        @cvar
      else
        if type_tag == :utf8
          "#{@cvar}.force_encoding('utf-8')"
        else
          @cvar
        end
      end
    end
  end

  # Implements argument processing for error handling arguments. These
  # arguments are not part of the introspected signature, but their
  # presence is indicated by the 'throws' attribute of the function.
  class ErrorArgument < Argument
    def prepare
      @callarg = @function_builder.new_var
    end

    def pre
      [ "#{@callarg} = FFI::MemoryPointer.new(:pointer).write_pointer nil" ]
    end

    def post
      [ "GirFFI::ArgHelper.check_error(#{@callarg})" ]
    end
  end

  # Argument builder that does nothing. Implements Null Object pattern.
  class NullArgument < Argument
    def prepare; end
  end
end
