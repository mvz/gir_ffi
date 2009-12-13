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

    def function_definition namespace, function
      gir = GirFFI::IRepository.default
      gir.require namespace.to_s, nil
      go = gir.find_by_name namespace, function.to_s

      sym = go.symbol
      argnames = go.args.map {|a| a.name}

      code = <<-CODE
	def #{function.to_s} #{argnames.join(', ')}
	  Lib.#{sym} #{argnames.join(', ')}
	end
      CODE
      return code.gsub(/(^\s*|\s*$)/, "")
    end

  end
end
