module GirFFI
  # Implements the creation of a Ruby function definition out of a GIR
  # IFunctionInfo.
  class FunctionDefinitionBuilder
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
      @inargs << arg.name
      prevar = new_var
      postvar = new_var
      case arg.type.tag
      when :int
	@pre << "#{prevar} = GirFFI::ArgHelper.int_to_inoutptr #{arg.name}"
	@post << "#{postvar} = GirFFI::ArgHelper.outptr_to_int #{prevar}"
      when :array
	case arg.type.param_type(0).tag
	when :utf8
	  # FIXME: Will need to take transfer-ownership GIR property into account.
	  @pre << "#{prevar} = GirFFI::ArgHelper.string_array_to_inoutptr #{arg.name}"
	  @post << "#{postvar} = GirFFI::ArgHelper.outptr_to_string_array #{prevar}, #{arg.name}.nil? ? 0 : #{arg.name}.size"
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
      case arg.type.tag
      when :interface
	if arg.type.interface.type == :callback
	  @inargs << arg.name
	  @pre << "#{@libmodule}::CALLBACKS << #{arg.name}"
	  @callargs << arg.name
	  return
	end
      when :void
	raise NotImplementedError unless arg.type.pointer?
	@inargs << arg.name
	prevar = new_var
	@pre << "#{prevar} = GirFFI::ArgHelper.object_to_inptr #{arg.name}"
	@callargs << prevar
	return
      end
      @inargs << arg.name
      @callargs << arg.name
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
  end
end
