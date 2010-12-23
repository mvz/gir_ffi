module GirFFI
  # Implements the creation of a Ruby function definition out of a GIR
  # IFunctionInfo.
  class FunctionDefinitionBuilder
    KEYWORDS =  [
      "alias", "and", "begin", "break", "case", "class", "def", "do",
      "else", "elsif", "end", "ensure", "false", "for", "if", "in",
      "module", "next", "nil", "not", "or", "redo", "rescue", "retry",
      "return", "self", "super", "then", "true", "undef", "unless",
      "until", "when", "while", "yield"
    ]

    def initialize info, libmodule
      @info = info
      @libmodule = libmodule
    end

    def generate
      setup_accumulators
      process_return_value
      @info.args.each {|a| process_arg a}
      adjust_accumulators
      return filled_out_template
    end

    private

    def setup_accumulators
      @inargs = []
      @callargs = []
      @retvals = []

      @pre = []
      @post = []

      @capture = ""

      @varno = 0
    end

    def process_arg arg
      case arg.direction
      when :inout
	process_inout_arg arg
      when :in
	process_in_arg arg
      when :out
	process_out_arg arg
      else
	raise ArgumentError
      end
    end

    def process_inout_arg arg
      raise NotImplementedError unless arg.ownership_transfer == :everything

      name = safe arg.name
      prevar = new_var
      postvar = new_var

      @inargs << name
      case arg.type.tag
      when :int, :int32
	@pre << "#{prevar} = GirFFI::ArgHelper.int_to_inoutptr #{name}"
	@post << "#{postvar} = GirFFI::ArgHelper.outptr_to_int #{prevar}"
      when :array
	case arg.type.param_type(0).tag
	when :utf8
	  @pre << "#{prevar} = GirFFI::ArgHelper.string_array_to_inoutptr #{name}"
	  @post << "#{postvar} = GirFFI::ArgHelper.outptr_to_string_array #{prevar}, #{name}.nil? ? 0 : #{name}.size"
	else
	  raise NotImplementedError
	end
      else
	raise NotImplementedError
      end
      @callargs << prevar
      @retvals << postvar
    end

    def process_out_arg arg
      type = arg.type
      tag = type.tag

      prevar = new_var
      postvar = new_var

      case tag
      when :interface
	iface = arg.type.interface
	if iface.type == :struct
	  @pre << "#{prevar} = #{iface.namespace}::#{iface.name}.new"
	  @post << "#{postvar} = #{prevar}"
	else
	  raise NotImplementedError,
	    "Don't know what to do with interface type #{iface.type}"
	end
      when :array
	size = type.array_fixed_size
	tag = arg.type.param_type(0).tag
	@pre << "#{prevar} = GirFFI::ArgHelper.pointer_pointer"
	@post << "#{postvar} = GirFFI::ArgHelper.outptr_to_#{tag}_array #{prevar}, #{size}"
      else
	@pre << "#{prevar} = GirFFI::ArgHelper.#{tag}_pointer"
	@post << "#{postvar} = GirFFI::ArgHelper.outptr_to_#{tag} #{prevar}"
      end
      @callargs << prevar
      @retvals << postvar
    end

    def process_in_arg arg
      name = safe arg.name
      type = arg.type
      tag = type.tag

      @inargs << name

      case tag
      when :interface
	if type.interface.type == :callback
	  # TODO: Use arg.scope to decide if this is needed.
	  procvar = new_var
	  @pre << "#{procvar} = GirFFI::ArgHelper.mapped_callback_args #{name}"
	  @pre << "::#{@libmodule}::CALLBACKS << #{procvar}"
	  @callargs << procvar
	else
	  @callargs << name
	end
      when :void
	raise NotImplementedError unless arg.type.pointer?
	prevar = new_var
	@pre << "#{prevar} = GirFFI::ArgHelper.object_to_inptr #{name}"
	@callargs << prevar
      when :array
	if type.array_fixed_size > 0
	  @pre << "GirFFI::ArgHelper.check_fixed_array_size #{type.array_fixed_size}, #{name}, \"#{name}\""
	end

	prevar = new_var

	case arg.type.param_type(0).tag
	when :int, :int32
	  @pre << "#{prevar} = GirFFI::ArgHelper.int_array_to_inptr #{name}"
	else
	  raise NotImplementedError
	end

	@callargs << prevar
      else
	@callargs << name
      end
    end

    def process_return_value
      type = @info.return_type
      tag = type.tag
      return if tag == :void
      cvar = new_var
      @capture = "#{cvar} = "

      if tag == :interface
	interface = type.interface
	namespace = interface.namespace
	name = interface.name
	GirFFI::Builder.build_class namespace, name
	retval = new_var
	@post << "#{retval} = ::#{namespace}::#{name}._real_new(#{cvar})"
	if interface.type == :object
	  @post << "GirFFI::ArgHelper.sink_if_floating(#{retval})"
	end
	@retvals << retval
      else
	@retvals << cvar
      end
    end

    def adjust_accumulators
      if @info.throws?
	errvar = new_var
	@pre << "#{errvar} = FFI::MemoryPointer.new(:pointer).write_pointer nil"
	@post.unshift "GirFFI::ArgHelper.check_error(#{errvar})"
	@callargs << errvar
      end

      @post << "return #{@retvals.join(', ')}" unless @retvals.empty?

      if @info.method?
	@callargs.unshift "self"
      end
    end

    def filled_out_template
      return <<-CODE
	def #{@info.name} #{@inargs.join(', ')}
	  #{@pre.join("\n")}
	  #{@capture}::#{@libmodule}.#{@info.symbol} #{@callargs.join(', ')}
	  #{@post.join("\n")}
	end
      CODE
    end

    def new_var
      @varno += 1
      "_v#{@varno}"
    end

    def safe name
      if KEYWORDS.include? name
	"#{name}_"
      else
	name
      end
    end
  end
end
