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

    def function_definition info
      sym = info.symbol
      argnames = info.args.map {|a| a.name}

      code = <<-CODE
	def #{info.name} #{argnames.join(', ')}
	  Lib.#{sym} #{argnames.join(', ')}
	end
      CODE
      return code.gsub(/(^\s*|\s*$)/, "")
    end

    def function_introspection_data namespace, function
      gir = GirFFI::IRepository.default
      gir.require namespace.to_s, nil
      return gir.find_by_name namespace, function.to_s
    end

    def attach_ffi_function klass, info
      sym = info.symbol
      argtypes = info.args.map {|a| itypeinfo_to_ffitype a.type}
      rt = itypeinfo_to_ffitype info.return_type

      klass.const_get(:Lib).module_eval do
	attach_function sym, argtypes, rt
      end
    end

    def itypeinfo_to_ffitype info
      return :pointer if info.pointer?
      return IRepository.type_tag_to_string(info.tag).to_sym
    end
  end
end
