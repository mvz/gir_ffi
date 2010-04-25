require 'girffi/helper/arg'
module GirFFI
  # FIXME: No sign of state here yet. Perhaps this should be a module.
  class Builder
    def build_object namespace, classname, box
      boxm = get_or_define_module ::Object, box.to_s
      namespacem = get_or_define_module boxm, namespace.to_s
      klass = get_or_define_class namespacem, classname.to_s

      klass.class_eval <<-CODE
	def method_missing method, *arguments
	end
      CODE

      gir = GirFFI::IRepository.default
      gir.require namespace, nil

      lb = get_or_define_module namespacem, :Lib
      lb.extend FFI::Library
      libs = gir.shared_library(namespace).split(/,/)
      lb.ffi_lib(*libs)
    end

    def build_module namespace, box
      boxm = get_or_define_module ::Object, box.to_s
      modul = get_or_define_module boxm, namespace.to_s

      modul.class_eval <<-CODE
	def self.method_missing method, *arguments
	  @@builder ||= GirFFI::Builder.new

	  go = @@builder.function_introspection_data "#{namespace}", method.to_s

	  return super if go.nil?
	  return super if go.type != :function

	  @@builder.attach_ffi_function self, go

	  (class << self; self; end).class_eval @@builder.function_definition(go)

	  self.send method, *arguments
	end
      CODE

      gir = GirFFI::IRepository.default
      gir.require namespace, nil

      lb = get_or_define_module modul, :Lib
      lb.extend FFI::Library
      libs = gir.shared_library(namespace).split(/,/)
      lb.ffi_lib(*libs)
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

    private

    def itypeinfo_to_ffitype info
      return :pointer if info.pointer?
      return IRepository.type_tag_to_string(info.tag).to_sym
    end

    def iarginfo_to_ffitype info
      return :pointer if info.direction == :inout
      return itypeinfo_to_ffitype info.type
    end

    def get_or_define_module parent, name
      unless parent.const_defined? name
	parent.const_set name, Module.new
      end
      parent.const_get name
    end

    def get_or_define_class parent, name
      unless parent.const_defined? name
	parent.const_set name, Class.new
      end
      parent.const_get name
    end
  end
end
