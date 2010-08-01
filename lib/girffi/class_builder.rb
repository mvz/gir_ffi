module GirFFI
  # Builds a class based on information found in the introspection
  # repository.
  class ClassBuilder
    def initialize namespace, classname, box
      @namespace = namespace
      @classname = classname
      @box = box
    end

    def generate
      build_class
    end

    private

    def build_class
      gir = IRepository.default
      gir.require @namespace, nil

      info = gir.find_by_name @namespace, @classname
      raise "Class #{@classname} not found in namespace #{@namespace}" if info.nil?
      parent = info.type == :object ? info.parent : nil
      if parent
	superclass = Builder.build_class parent.namespace, parent.name, @box
      end

      namespacem = Builder.build_module @namespace, @box
      klass = BuilderHelper.get_or_define_class namespacem, @classname, superclass

      unless klass.instance_methods(false).map(&:to_sym).include? :method_missing
	@lib = namespacem.const_get :Lib
	klass.class_eval instance_method_missing_definition
	klass.class_eval class_method_missing_definition

	unless parent
	  klass.class_exec { include ClassBase }
	  (class << klass; self; end).class_exec { alias_method :_real_new, :new }
	end

	unless info.type == :object and info.abstract?
	  ctor = info.find_method 'new'
	  if not ctor.nil? and ctor.constructor?
	    Builder.setup_function_or_method klass, @lib, ctor
	  end
	end
      end
      klass
    end

    def instance_method_missing_definition
      InstanceMethodMissingDefinitionBuilder.new(@lib, @namespace, @classname).generate
    end

    def class_method_missing_definition
      ClassMethodMissingDefinitionBuilder.new(@lib, @namespace, @classname).generate
    end
  end
end
