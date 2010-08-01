module GirFFI
  # Base class for builders of #method_missing definitions.
  class MethodMissingDefinitionBuilder
    def initialize lib, namespace
      @lib = lib
      @namespace = namespace
    end

    def generate
      args = arguments.map {|arg| "\"#{arg}\""}

      return <<-CODE
	def #{slf}method_missing method, *arguments, &block
	  result = GirFFI::Builder.#{fn} #{args.join ', '}, #{libs.join ', '}, self, method.to_s
	  return super unless result
	  if block.nil?
	    self.send method, *arguments
	  else
	    self.send method, *arguments, &block
	  end
	end
      CODE
    end
  end

  # Builds a #method_missing for a module. This method_missing will be
  # called for missing module methods; these modules are not meant for
  # #include'ing.
  class ModuleMethodMissingDefinitionBuilder < MethodMissingDefinitionBuilder
    private

    def slf; "self."; end
    def fn; "setup_function"; end
    def arguments; [@namespace]; end
    def libs; [@lib]; end
  end

  # Builds a #method_missing for missing instance methods.
  class InstanceMethodMissingDefinitionBuilder < MethodMissingDefinitionBuilder
    def initialize lib, modul, namespace, classname
      super lib, namespace
      @classname = classname
      @module = modul
    end

    private

    def slf; ""; end
    def fn; "setup_method"; end
    def arguments; [@namespace, @classname]; end
    def libs; [@lib, @module]; end
  end

  # Builds a #method_missing for missing class methods.
  class ClassMethodMissingDefinitionBuilder < InstanceMethodMissingDefinitionBuilder
    private

    def slf; "self."; end
  end

end

