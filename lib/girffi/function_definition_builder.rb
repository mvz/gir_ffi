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

      @varno = 0
    end

    def process_arg arg
      case arg.direction
      when :inout
	process_inout_arg arg
      when :in
	process_in_arg arg
      else
	raise NotImplementedError
      end
    end

    def process_inout_arg arg
      raise NotImplementedError unless arg.ownership_transfer == :everything

      name = safe arg.name
      prevar = new_var
      postvar = new_var

      @inargs << name
      case arg.type.tag
      when :int
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

    def process_in_arg arg
      name = safe arg.name
      type = arg.type
      tag = type.tag

      @inargs << name

      if tag == :interface and type.interface.type == :callback
	# TODO: Use arg.scope to decide if this is needed.
	procvar = new_var
	@pre << "#{procvar} = GirFFI::ArgHelper.mapped_callback_args #{name}"
	@pre << "#{@libmodule}::CALLBACKS << #{procvar}"
	@callargs << procvar
	#@pre << "#{@libmodule}::CALLBACKS << #{name}"
	#@callargs << name
      elsif tag == :void
	raise NotImplementedError unless arg.type.pointer?
	prevar = new_var
	@pre << "#{prevar} = GirFFI::ArgHelper.object_to_inptr #{name}"
	@callargs << prevar
      else
	@callargs << name
      end
    end

    def adjust_accumulators
      @post << "return #{@retvals.join(', ')}" unless @retvals.empty?

      if @info.method?
	@callargs.unshift "@gobj"
      end
    end

    def filled_out_template
      return <<-CODE
	def #{@info.name} #{@inargs.join(', ')}
	  #{@pre.join("\n")}
	  #{@libmodule}.#{@info.symbol} #{@callargs.join(', ')}
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
