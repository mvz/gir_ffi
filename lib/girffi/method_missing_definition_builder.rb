module GirFFI
  class MethodMissingDefinitionBuilder
    def initialize lib, namespace
      @lib = lib
      @namespace = namespace
    end

    def generate
      args = arguments.map {|arg| "\"#{arg}\""}

      return <<-CODE
	def #{slf}method_missing method, *arguments, &block
	  result = GirFFI::Builder.#{fn} #{args.join ', '}, #{@lib}, self, method.to_s
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

  class ModuleMethodMissingDefinitionBuilder < MethodMissingDefinitionBuilder
    private

    def slf; "self."; end
    def fn; "setup_function"; end
    def arguments; [@namespace]; end
  end

  class ClassMethodMissingDefinitionBuilder < MethodMissingDefinitionBuilder
    def initialize lib, namespace, classname
      super lib, namespace
      @classname = classname
    end

    private

    def slf; "self."; end
    def fn; "setup_method"; end
    def arguments; [@namespace, @classname]; end
  end

  class InstanceMethodMissingDefinitionBuilder < MethodMissingDefinitionBuilder
    def initialize lib, namespace, classname
      super lib, namespace
      @classname = classname
    end

    private

    def slf; ""; end
    def fn; "setup_method"; end
    def arguments; [@namespace, @classname]; end
  end
end

