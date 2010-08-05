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
      get_gir_info
      instantiate_module
      case @info.type
	when :object, :struct
	  instantiate_class
	  setup_class unless already_set_up
	when :enum, :flags
	  @klass = BuilderHelper.optionally_define_constant @module, @classname do
	    vals = @info.values.map {|v| [v.name.to_sym, v.value]}.flatten
	    @lib.enum(@classname.to_sym, vals)
	  end
      end
      @klass
    end

    def get_gir_info
      gir = IRepository.default
      gir.require @namespace, nil

      @info = gir.find_by_name @namespace, @classname
      raise "Class #{@classname} not found in namespace #{@namespace}" if @info.nil?
    end

    def get_superclass
      @parent = @info.type == :object ? @info.parent : nil
      if @parent
	@superclass = Builder.build_class @parent.namespace, @parent.name, @box
      else
	@superclass = FFI::Struct
      end
    end

    def instantiate_module
      @module = Builder.build_module @namespace, @box
      @lib = @module.const_get :Lib
    end

    def instantiate_class
      get_superclass
      @klass = BuilderHelper.get_or_define_class @module, @classname, @superclass
    end

    def setup_class
      setup_method_missing
      setup_base
      setup_layout
      setup_constructor
    end

    def setup_base
      return if @parent
      class << @klass
	self.class_exec { alias_method :_real_new, :new }
      end
    end

    def setup_constructor
      ctor = @info.find_method 'new'
      if not ctor.nil? and ctor.constructor?
	Builder.setup_function_or_method @klass, @module, @lib, ctor
      end
    end

    def setup_method_missing
      @klass.class_eval instance_method_missing_definition
      @klass.class_eval class_method_missing_definition
    end

    def setup_layout
      layoutspec = []
      @info.fields.each do |f|
	layoutspec << f.name.to_sym

	ffitype = Builder.itypeinfo_to_ffitype @module, @lib, f.type, @box

	layoutspec << ffitype

	layoutspec << f.offset
      end
      @klass.class_exec { layout *layoutspec }
    end

    def instance_method_missing_definition
      InstanceMethodMissingDefinitionBuilder.new(@lib, @module, @namespace, @classname).generate
    end

    def class_method_missing_definition
      ClassMethodMissingDefinitionBuilder.new(@lib, @module, @namespace, @classname).generate
    end

    def already_set_up
      @klass.instance_methods(false).map(&:to_sym).include? :method_missing
    end
  end
end
