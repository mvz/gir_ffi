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

    def subtype_tag
      st = type_info.param_type(0)
      t = st.tag
      case t
      when :GType
        return :gtype
      when :interface
        raise NotImplementedError if st.pointer?
        iface = st.interface
        if iface.name == 'Value' and iface.namespace == 'GObject'
          return :gvalue
        else
          raise NotImplementedError
        end
      else
        return t
      end
    end

    def argument_class_name
      iface = type_info.interface
      "::#{iface.namespace}::#{iface.name}"
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
                ArrayInArgument
              when :glist, :gslist
                ListInArgument
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
  class ArrayInArgument < InArgument
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

  # Implements argument processing for gslist arguments with direction :in.
  class ListInArgument < InArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.#{subtype_tag}_array_to_#{type_tag} #{@name}" ]
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
      klass = case arginfo.argument_type.tag
              when :interface
                InterfaceOutArgument
              when :array
                ArrayOutArgument
              when :gslist
                GSListOutArgument
              else
                RegularOutArgument
              end
      klass.new function_builder, arginfo, libmodule
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
  class ArrayOutArgument < OutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
    end

    def postpost
      size = array_size
      tag = subtype_tag

      pp = [ "#{@retname} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{@callarg}, #{size}" ]

      if @arginfo.ownership_transfer == :everything
	if tag == :utf8
	  pp << "GirFFI::ArgHelper.cleanup_ptr_array_ptr #{@callarg}, #{size}"
	else
	  pp << "GirFFI::ArgHelper.cleanup_ptr_ptr #{@callarg}"
	end
      end

      pp
    end
  end

  # Implements argument processing for gslist arguments with direction
  # :out.
  class GSListOutArgument < OutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
    end

    def postpost
      [ "#{@retname} = GirFFI::ArgHelper.outgslist_to_#{subtype_tag}_array #{@callarg}" ]
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
      raise NotImplementedError unless arginfo.ownership_transfer == :everything

      klass = case arginfo.argument_type.tag
              when :interface
                raise NotImplementedError
              when :array
                ArrayInOutArgument
              else
                RegularInOutArgument
              end

      klass.new function_builder, arginfo, libmodule
    end
  end

  # Implements argument processing for array arguments with direction
  # :inout.
  class ArrayInOutArgument < InOutArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.#{subtype_tag}_array_to_inoutptr #{@name}" ]
    end

    def post
      tag = subtype_tag
      size = @length_arg.retname
      pst = [ "#{@retname} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{@callarg}, #{size}" ]
      if tag == :utf8
        pst << "GirFFI::ArgHelper.cleanup_ptr_array_ptr #{@callarg}, #{size}"
      else
        pst << "GirFFI::ArgHelper.cleanup_ptr_ptr #{@callarg}"
      end
      pst
    end
  end

  # Implements argument processing for arguments with direction
  # :inout that are neither arrays nor 'interfaces'.
  class RegularInOutArgument < InOutArgument
    def post
      [ "#{@retname} = GirFFI::ArgHelper.outptr_to_#{type_tag} #{@callarg}",
        "GirFFI::ArgHelper.cleanup_ptr #{@callarg}" ]
    end

    def pre
      pr = []
      if @array_arg
        pr << "#{@name} = #{@array_arg.name}.length"
      end
      pr << "#{@callarg} = GirFFI::ArgHelper.#{type_tag}_to_inoutptr #{@name}"
      pr
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
                ArrayReturnValue
              when :glist, :gslist
                ListReturnValue
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
      [ "#{@retname} = #{defining_class_name}.constructor_wrap(#{@cvar})" ]
    end
  end

  # Implements argument processing for array return values.
  class ArrayReturnValue < ReturnValue
    def post
      size = array_size

      [ "#{@retname} = GirFFI::ArgHelper.ptr_to_#{subtype_tag}_array #{@cvar}, #{size}" ]
    end
  end

  # Implements argument processing for GSList return values.
  class ListReturnValue < ReturnValue
    def post
      [ "#{@retname} = GirFFI::ArgHelper.#{type_tag}_to_#{subtype_tag}_array #{@cvar}" ]
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
