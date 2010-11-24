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
	  result = gir_ffi_builder.#{fn} method.to_s
	  return super unless result
	  self.send method, *arguments, &block
	end
      CODE
    end
  end

  # Builds a #method_missing for missing instance methods.
  class InstanceMethodMissingDefinitionBuilder < MethodMissingDefinitionBuilder
    def initialize lib, modul, namespace, classname
      super lib, namespace
      @classname = classname
      @module = modul
    end

    def generate;
      return <<-CODE
	def #{slf}method_missing method, *arguments, &block
	  super
	end
      CODE
    end
    private

    def slf; ""; end
    def fn; "setup_instance_method"; end
    def arguments; [@namespace, @classname]; end
    def libs; [@lib, @module]; end
  end

  # Builds a #method_missing for missing class methods.
  class ClassMethodMissingDefinitionBuilder < InstanceMethodMissingDefinitionBuilder
    private

    def slf; "self."; end
    def fn; "setup_method"; end
  end

end

