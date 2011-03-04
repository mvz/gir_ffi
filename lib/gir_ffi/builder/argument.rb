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

    attr_reader :arginfo, :callarg, :pre, :post, :postpost

    attr_accessor :length_arg, :inarg, :retval

    def initialize function_builder, arginfo=nil, libmodule=nil
      @arginfo = arginfo
      @inarg = nil
      @callarg = nil
      @retval = nil
      @retname = nil
      @name = nil
      @pre = []
      @post = []
      @postpost = []
      @function_builder = function_builder
      @libmodule = libmodule
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
    def process
      iface = @arginfo.type.interface
      @pre << "#{@callarg} = GirFFI::ArgHelper.wrap_in_callback_args_mapper \"#{iface.namespace}\", \"#{iface.name}\", #{@inarg}"
      @pre << "::#{@libmodule}::CALLBACKS << #{@callarg}"
    end
  end

  # Implements argument processing for void pointer arguments with
  # direction :in.
  class VoidInArgument < InArgument
    def process
      @pre << "#{@callarg} = GirFFI::ArgHelper.object_to_inptr #{@inarg}"
    end
  end

  # Implements argument processing for array arguments with direction :in.
  class ArrayInArgument < InArgument
    def process
      type = @arginfo.type

      if type.array_fixed_size > 0
	@pre << "GirFFI::ArgHelper.check_fixed_array_size #{type.array_fixed_size}, #{@inarg}, \"#{@inarg}\""
      elsif type.array_length > -1
	idx = type.array_length
	lenvar = @length_arg.inarg
	@length_arg.inarg = nil
	@length_arg.pre.unshift "#{lenvar} = #{@inarg}.nil? ? 0 : #{@inarg}.length"
      end

      tag = @arginfo.type.param_type(0).tag.to_s.downcase
      @pre << "#{@callarg} = GirFFI::ArgHelper.#{tag}_array_to_inptr #{@inarg}"
      unless @arginfo.ownership_transfer == :everything
	if tag == :utf8
	  @post << "GirFFI::ArgHelper.cleanup_ptr_ptr #{@callarg}"
	else
	  @post << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
	end
      end
    end
  end

  # Implements argument processing for UTF8 string arguments with direction
  # :in.
  class Utf8InArgument < InArgument
    def process
      @pre << "#{@callarg} = GirFFI::ArgHelper.utf8_to_inptr #{@name}"
      # TODO:
      #@post << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
    end

  end

  # Implements argument processing for arguments with direction :in whose
  # type-specific processing is left to FFI (e.g., ints and floats, and
  # objects that implement to_ptr.).
  class RegularInArgument < InArgument
    def process
      @pre << "#{@callarg} = #{@name}"
    end
  end

  # Implements argument processing for arguments with direction :out.
  class OutArgument < Argument
    def prepare
      @name = safe(@arginfo.name)
      @callarg = @function_builder.new_var
      @retname = @retval = @function_builder.new_var
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
    def process
      iface = @arginfo.type.interface
      klass = "#{iface.namespace}::#{iface.name}"

      if @arginfo.caller_allocates?
	@pre << "#{@callarg} = #{klass}.allocate"
	@post << "#{@retval} = #{@callarg}"
      else
	@pre << "#{@callarg} = GirFFI::ArgHelper.pointer_outptr"
	@post << "#{@retval} = #{klass}.wrap GirFFI::ArgHelper.outptr_to_pointer(#{@callarg})"
      end
    end
  end

  # Implements argument processing for array arguments with direction
  # :out.
  class ArrayOutArgument < OutArgument
    def process
      @pre << "#{@callarg} = GirFFI::ArgHelper.pointer_outptr"

      type = @arginfo.type
      tag = type.param_type(0).tag
      size = type.array_fixed_size
      idx = type.array_length

      if size <= 0
	if idx > -1
	  size = @length_arg.retval
	  @length_arg.retval = nil
	else
	  raise NotImplementedError
	end
      end

      @postpost << "#{@retval} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{@callarg}, #{size}"

      if @arginfo.ownership_transfer == :everything
	if tag == :utf8
	  @postpost << "GirFFI::ArgHelper.cleanup_ptr_array_ptr #{@callarg}, #{size}"
	else
	  @postpost << "GirFFI::ArgHelper.cleanup_ptr_ptr #{@callarg}"
	end
      end
    end
  end

  # Implements argument processing for arguments with direction
  # :out that are neither arrays nor 'interfaces'.
  class RegularOutArgument < OutArgument
    def process
      tag = @arginfo.type.tag
      @pre << "#{@callarg} = GirFFI::ArgHelper.#{tag}_outptr"
      @post << "#{@retname} = GirFFI::ArgHelper.outptr_to_#{tag} #{@callarg}"
      if @arginfo.ownership_transfer == :everything
	@post << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
      end
    end
  end

  # Implements argument processing for arguments with direction :inout.
  class InOutArgument < Argument
    def prepare
      @name = safe(@arginfo.name)
      @callarg = @function_builder.new_var
      @inarg = @name
      @retname = @retval = @function_builder.new_var
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
    def process
      tag = @arginfo.type.param_type(0).tag
      @pre << "#{@callarg} = GirFFI::ArgHelper.#{tag}_array_to_inoutptr #{@inarg}"
      if @arginfo.type.array_length > -1
	idx = @arginfo.type.array_length
	rv = @length_arg.retval
	@length_arg.retval = nil
	lname = @length_arg.inarg
	@length_arg.inarg = nil
	@length_arg.pre.unshift "#{lname} = #{@inarg}.length"
	@post << "#{@retval} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{@callarg}, #{rv}"
	if tag == :utf8
	  @post << "GirFFI::ArgHelper.cleanup_ptr_array_ptr #{@callarg}, #{rv}"
	else
	  @post << "GirFFI::ArgHelper.cleanup_ptr_ptr #{@callarg}"
	end
      else
	raise NotImplementedError
      end
    end
  end

  # Implements argument processing for arguments with direction
  # :inout that are neither arrays nor 'interfaces'.
  class RegularInOutArgument < InOutArgument
    def process
      tag = @arginfo.type.tag
      @pre << "#{@callarg} = GirFFI::ArgHelper.#{tag}_to_inoutptr #{@inarg}"
      @post << "#{@retval} = GirFFI::ArgHelper.outptr_to_#{tag} #{@callarg}"
      @post << "GirFFI::ArgHelper.cleanup_ptr #{@callarg}"
    end
  end

  # Implements argument processing for return values.
  class ReturnValue < Argument
    attr_reader :cvar

    def prepare
      @cvar = @function_builder.new_var
      @retval = @function_builder.new_var
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
    def process; end
  end

  # Implements argument processing for interface return values (interfaces
  # and structs, but not objects, which need special handling for
  # polymorphism and constructors.
  class InterfaceReturnValue < ReturnValue
    def process
      type = @arginfo.return_type
      interface = type.interface
      namespace = interface.namespace
      name = interface.name

      GirFFI::Builder.build_class namespace, name
      @post << "#{@retval} = ::#{namespace}::#{name}.wrap(#{@cvar})"
    end
  end

  # Implements argument processing for object return values.
  class ObjectReturnValue < ReturnValue
    def process
      interface = type.interface
      namespace = interface.namespace
      name = interface.name

      if @arginfo.constructor?
        GirFFI::Builder.build_class namespace, name
        @post << "#{@retval} = ::#{namespace}::#{name}.wrap(#{@cvar})"
        if is_subclass_of_initially_unowned interface
          @post << "GirFFI::GObject.object_ref_sink(#{@retval})"
        end
      else
        @post << "#{@retval} = GirFFI::ArgHelper.object_pointer_to_object(#{@cvar})"
      end
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
    def process
      type = @arginfo.return_type
      tag = type.param_type(0).tag
      size = type.array_fixed_size
      idx = type.array_length

      if size > 0
	@post << "#{@retval} = GirFFI::ArgHelper.ptr_to_#{tag}_array #{@cvar}, #{size}"
      elsif idx > -1
	lendata = @length_arg #@data[idx]
	rv = lendata.retval
	lendata.retval = nil
	@post << "#{@retval} = GirFFI::ArgHelper.ptr_to_#{tag}_array #{@cvar}, #{rv}"
      end
    end
  end

  # Implements argument processing for other return values.
  class RegularReturnValue < ReturnValue
    def process
      @retval = @cvar
    end
  end

  # Implements argument processing for error handling arguments. These
  # arguments are not part of the introspected signature, but their
  # presence is indicated by the 'throws' attribute of the function.
  class ErrorArgument < Argument
    def prepare
      @callarg = @function_builder.new_var
    end

    def process
      @pre << "#{@callarg} = FFI::MemoryPointer.new(:pointer).write_pointer nil"
      @post << "GirFFI::ArgHelper.check_error(#{@callarg})"
    end
  end

  # Argument builder that does nothing. Implements Null Object pattern.
  class NullArgument < Argument
    def prepare; end
    def process; end
  end
end
