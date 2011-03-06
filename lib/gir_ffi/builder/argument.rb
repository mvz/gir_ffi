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

    attr_reader :arginfo, :callarg, :pre, :post, :postpost, :name, :retname

    attr_accessor :length_arg, :inarg, :retval, :length_arg_for

    def initialize function_builder, arginfo=nil, libmodule=nil
      @arginfo = arginfo
      @inarg = nil
      @callarg = nil
      @retname = nil
      @name = nil
      @pre = []
      @post = []
      @postpost = []
      @function_builder = function_builder
      @libmodule = libmodule
      @length_arg = nil
      @length_arg_for = nil
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

    def type
      @arginfo.type
    end

    def safe name
      if KEYWORDS.include? name
	"#{name}_"
      else
	name
      end
    end

    def inarg
      @length_arg_for.nil? ? @inarg : nil
    end

    def retval
      @length_arg_for.nil? ? @retname : nil
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
      type = arginfo.type
      klass = case type.tag
              when :interface
                if type.interface.type == :callback
                  CallbackInArgument
                else
                  RegularInArgument
                end
              when :void
                VoidInArgument
              when :array
                ArrayInArgument
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
      iface = @arginfo.type.interface
      [ "#{@callarg} = GirFFI::ArgHelper.wrap_in_callback_args_mapper \"#{iface.namespace}\", \"#{iface.name}\", #{@inarg}",
        "::#{@libmodule}::CALLBACKS << #{@callarg}" ]
    end
  end

  # Implements argument processing for void pointer arguments with
  # direction :in.
  class VoidInArgument < InArgument
    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.object_to_inptr #{@inarg}" ]
    end
  end

  # Implements argument processing for array arguments with direction :in.
  class ArrayInArgument < InArgument
    def subtype_tag
      @arginfo.type.param_type(0).tag.to_s.downcase
    end

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
      if not @length_arg
        pr << "GirFFI::ArgHelper.check_fixed_array_size #{@arginfo.type.array_fixed_size}, #{@inarg}, \"#{@inarg}\""
      end
      pr << "#{@callarg} = GirFFI::ArgHelper.#{subtype_tag}_array_to_inptr #{@inarg}"
      pr
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
      if @length_arg_for
	pr << "#{@name} = #{@length_arg_for.name}.nil? ? 0 : #{@length_arg_for.name}.length"
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
      klass = case arginfo.type.tag
              when :interface
                InterfaceOutArgument
              when :array
                ArrayOutArgument
              else
                RegularOutArgument
              end
      klass.new function_builder, arginfo, libmodule
    end
  end

  # Implements argument processing for interface arguments with direction
  # :out (structs, objects, etc.).
  class InterfaceOutArgument < OutArgument
    def klass
      iface = @arginfo.type.interface
      "#{iface.namespace}::#{iface.name}"
    end

    def pre
      if @arginfo.caller_allocates?
	[ "#{@callarg} = #{klass}.allocate" ]
      else
	[ "#{@callarg} = GirFFI::ArgHelper.pointer_outptr" ]
      end
    end

    def post
      if @arginfo.caller_allocates?
	[ "#{@retname} = #{@callarg}" ]
      else
	[ "#{@retname} = #{klass}.wrap GirFFI::ArgHelper.outptr_to_pointer(#{@callarg})" ]
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
      type = @arginfo.type

      size = if @length_arg
               @length_arg.retname
             else
               type.array_fixed_size
             end

      tag = type.param_type(0).tag

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

  # Implements argument processing for arguments with direction
  # :out that are neither arrays nor 'interfaces'.
  class RegularOutArgument < OutArgument
    def type_tag
      @arginfo.type.tag
    end

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

      klass = case arginfo.type.tag
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
    def subtype_tag
      @arginfo.type.param_type(0).tag
    end

    def pre
      [ "#{@callarg} = GirFFI::ArgHelper.#{subtype_tag}_array_to_inoutptr #{@inarg}" ]
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
    def type_tag
      @arginfo.type.tag
    end

    def post
      [ "#{@retname} = GirFFI::ArgHelper.outptr_to_#{type_tag} #{@callarg}",
        "GirFFI::ArgHelper.cleanup_ptr #{@callarg}" ]
    end

    def pre
      pr = []
      if @length_arg_for
        pr << "#{@name} = #{@length_arg_for.name}.length"
      end
      pr << "#{@callarg} = GirFFI::ArgHelper.#{type_tag}_to_inoutptr #{@inarg}"
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

    def type
      @arginfo.return_type
    end

    def self.build function_builder, arginfo
      type = arginfo.return_type
      klass = case type.tag
              when :void
                VoidReturnValue
              when :interface
                case type.interface.type
                when :interface, :struct
                  InterfaceReturnValue
                when :object
                  ObjectReturnValue
                else
                  RegularReturnValue
                end
              when :array
                ArrayReturnValue
              else
                RegularReturnValue
              end
      klass.new function_builder, arginfo, nil
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
      interface = @arginfo.return_type.interface
      namespace = interface.namespace
      name = interface.name

      GirFFI::Builder.build_class namespace, name
      [ "#{@retname} = ::#{namespace}::#{name}.wrap(#{@cvar})" ]
    end
  end

  # Implements argument processing for object return values.
  class ObjectReturnValue < ReturnValue
    def post
      pst = []
      if @arginfo.constructor?
        interface = type.interface
        namespace = interface.namespace
        name = interface.name

        GirFFI::Builder.build_class namespace, name
        pst << "#{@retname} = ::#{namespace}::#{name}.wrap(#{@cvar})"
        if is_subclass_of_initially_unowned interface
          pst << "GirFFI::GObject.object_ref_sink(#{@retname})"
        end
      else
        pst << "#{@retname} = GirFFI::ArgHelper.object_pointer_to_object(#{@cvar})"
      end
      pst
    end

    def is_subclass_of_initially_unowned interface
      if interface.namespace == "GObject" and interface.name == "InitiallyUnowned"
        true
      elsif interface.parent
        is_subclass_of_initially_unowned interface.parent
      else
        false
      end
    end
  end

  # Implements argument processing for array return values.
  class ArrayReturnValue < ReturnValue
    def subtype_tag
      @arginfo.return_type.param_type(0).tag
    end

    def post
      type = @arginfo.return_type
      size = type.array_fixed_size

      if size <= 0
	size = @length_arg.retname
      end
      [ "#{@retname} = GirFFI::ArgHelper.ptr_to_#{subtype_tag}_array #{@cvar}, #{size}" ]
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
