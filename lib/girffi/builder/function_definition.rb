module GirFFI
  class Builder
    class FunctionDefinition
      def initialize info
	@info = info
      end
      def generate
	info = @info
	sym = info.symbol

	inargs = []
	callargs = []
	retvals = []

	blockarg = nil

	pre = []
	post = []

	varno = 1

	info.args.each do |a|
	  case a.direction
	  when :inout
	    inargs << a.name
	    prevar = "_v#{varno}"
	    postvar = "_v#{varno+1}"
	    case a.type.tag 
	    when :int
	      pre << "#{prevar} = GirFFI::Helper::Arg.int_to_inoutptr #{a.name}"
	      post << "#{postvar} = GirFFI::Helper::Arg.outptr_to_int #{prevar}"
	    when :array
	      case a.type.param_type(0).tag
	      when :utf8
		pre << "#{prevar} = GirFFI::Helper::Arg.string_array_to_inoutptr #{a.name}"
		post << "#{postvar} = GirFFI::Helper::Arg.outptr_to_string_array #{prevar}, #{a.name}.nil? ? 0 : #{a.name}.size"
	      else
		raise NotImplementedError
	      end
	    else
	      raise NotImplementedError
	    end
	    callargs << prevar
	    retvals << postvar
	    varno += 2
	  when :in
	    case a.type.tag
	    when :interface
	      if a.type.interface.type == :callback and blockarg.nil?
		# TODO: What if blockarg is taken?
		blockarg = a.name
		prevar = "_v#{varno}"
		pre << "#{prevar} = #{a.name}.to_proc"
		pre << "Lib::CALLBACKS << #{prevar}"
		callargs << prevar
		varno += 1
	      else
		inargs << a.name
		callargs << a.name
	      end
	    when :void
	      if a.type.pointer?
		inargs << a.name
		prevar = "_v#{varno}"
		pre << "#{prevar} = GirFFI::Helper::Arg.object_to_inptr #{a.name}"
		callargs << prevar
		varno += 1
	      else
		raise NotImplementedError
	      end
	    else
	      inargs << a.name
	      callargs << a.name
	    end
	  else
	    raise NotImplementedError
	  end
	end
	inargs << "&#{blockarg}" unless blockarg.nil?
	post << "return #{retvals.join(', ')}" unless retvals.empty?

	if info.method?
	  callargs.unshift "@gobj"
	end

	return <<-CODE
	  def #{info.name} #{inargs.join(', ')}
	    #{pre.join("\n")}
	    Lib.#{sym} #{callargs.join(', ')}
	    #{post.join("\n")}
	  end
	CODE
      end
    end
  end
end

