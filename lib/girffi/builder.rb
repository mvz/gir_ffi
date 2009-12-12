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
  end
end
