module GirFFI
  class Builder
    class FunctionDefinition
      def initialize info
	@info = info
	@generated = false
      end

      def generate
	unless @generated
	  setup_accumulators

	  @info.args.each do |a|
	    process_arg a
	  end

	  adjust_accumulators

	  @generated = true
	end

	return filled_out_template
      end

      private

      def setup_accumulators
	@inargs = []
	@callargs = []
	@retvals = []

	@blockarg = nil

	@pre = []
	@post = []

	@varno = 0
      end

      def process_arg a
	case a.direction
	when :inout
	  process_inout_arg a
	when :in
	  process_in_arg a
	else
	  raise NotImplementedError
	end
      end

      def process_inout_arg a
	@inargs << a.name
	prevar = new_var
	postvar = new_var
	case a.type.tag 
	when :int
	  @pre << "#{prevar} = GirFFI::Helper::Arg.int_to_inoutptr #{a.name}"
	  @post << "#{postvar} = GirFFI::Helper::Arg.outptr_to_int #{prevar}"
	when :array
	  case a.type.param_type(0).tag
	  when :utf8
	    @pre << "#{prevar} = GirFFI::Helper::Arg.string_array_to_inoutptr #{a.name}"
	    @post << "#{postvar} = GirFFI::Helper::Arg.outptr_to_string_array #{prevar}, #{a.name}.nil? ? 0 : #{a.name}.size"
	  else
	    raise NotImplementedError
	  end
	else
	  raise NotImplementedError
	end
	@callargs << prevar
	@retvals << postvar
      end

      def process_in_arg a
	case a.type.tag
	when :interface
	  if a.type.interface.type == :callback and @blockarg.nil?
	    # TODO: What if @blockarg is taken?
	    @blockarg = a.name
	    prevar = new_var
	    @pre << "#{prevar} = #{a.name}.to_proc"
	    @pre << "Lib::CALLBACKS << #{prevar}"
	    @callargs << prevar
	    return
	  end
	when :void
	  raise NotImplementedError unless a.type.pointer?
	  @inargs << a.name
	  prevar = new_var
	  @pre << "#{prevar} = GirFFI::Helper::Arg.object_to_inptr #{a.name}"
	  @callargs << prevar
	  return
	end
	@inargs << a.name
	@callargs << a.name
      end

      def adjust_accumulators
	@inargs << "&#{@blockarg}" unless @blockarg.nil?
	@post << "return #{@retvals.join(', ')}" unless @retvals.empty?

	if @info.method?
	  @callargs.unshift "@gobj"
	end
      end

      def filled_out_template
	return <<-CODE
	  def #{@info.name} #{@inargs.join(', ')}
	    #{@pre.join("\n")}
	    Lib.#{@info.symbol} #{@callargs.join(', ')}
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
end

