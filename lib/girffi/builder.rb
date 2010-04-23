require 'girffi/helper/arg'
module GirFFI
  class Builder
    def build_object namespace, classname, box
      ::Object.const_set box.to_s, boxm = Module.new
      boxm.const_set namespace.to_s, namespacem = Module.new
      namespacem.const_set classname.to_s, klass = Class.new

      gir = GirFFI::IRepository.default
      gir.require namespace, nil
      info = gir.find_by_name namespace, classname
      info.methods.each do |m|
	klass.class_eval <<-CODE
	  def #{m.name}; end
	CODE
      end
    end

    # FIXME: Methods that follow should be private
    def function_definition info
      sym = info.symbol
      argnames = info.args.map {|a| a.name}

      varno = 1

      inargs = []
      callargs = []
      retvals = []

      pre = []
      post = []

      info.args.each do |a|
	inargs << a.name if [:in, :inout].include? a.direction
	case a.direction
	when :inout
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
	      post << "#{postvar} = GirFFI::Helper::Arg.outptr_to_string_array #{prevar}, #{a.name}.size"
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
	  callargs << a.name
	else
	  raise NotImplementedError
	end
      end

      post << "return #{retvals.join(', ')}" unless retvals.empty?

      return <<-CODE
	def #{info.name} #{inargs.join(', ')}
	  #{pre.join("\n")}
	  Lib.#{sym} #{callargs.join(', ')}
	  #{post.join("\n")}
	end
      CODE
    end

    def function_introspection_data namespace, function
      gir = GirFFI::IRepository.default
      gir.require namespace.to_s, nil
      return gir.find_by_name namespace, function.to_s
    end

    def attach_ffi_function klass, info
      sym = info.symbol
      argtypes = ffi_function_argument_types info
      rt = ffi_function_return_type info

      klass.const_get(:Lib).module_eval do
	attach_function sym, argtypes, rt
      end
    end

    def ffi_function_argument_types info
      info.args.map {|a| iarginfo_to_ffitype a}
    end

    def ffi_function_return_type info
      itypeinfo_to_ffitype info.return_type
    end

    def itypeinfo_to_ffitype info
      return :pointer if info.pointer?
      return IRepository.type_tag_to_string(info.tag).to_sym
    end

    def iarginfo_to_ffitype info
      return :pointer if info.direction == :inout
      return itypeinfo_to_ffitype info.type
    end
  end
end
