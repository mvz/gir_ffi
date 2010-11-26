module GirFFI
  # Builds a class based on information found in the introspection
  # repository.
  class ClassBuilder
    def initialize namespace, classname
      @namespace = namespace
      @classname = classname
    end

    def generate
      build_class
    end

    def setup_method method
      definition = prepare_method method.to_s

      return false if definition.nil?

      klass = build_class
      meta = (class << klass; self; end)
      meta.class_eval definition

      true
    end

    def setup_instance_method method
      klass = build_class
      definition = prepare_method method.to_s

      if definition.nil?
	if @info.parent
	  return klass.superclass.gir_ffi_builder.setup_instance_method method
	else
	  return false
	end
      end

      klass.class_eval "undef #{method}"
      klass.class_eval definition

      true
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
	@superclass = Builder.build_class @parent.namespace, @parent.name
      else
	@superclass = GirFFI::ClassBase
      end
    end

    def instantiate_module
      @module = Builder.build_module @namespace
      @lib = @module.const_get :Lib
    end

    def instantiate_class
      get_superclass
      @klass = BuilderHelper.get_or_define_class @module, @classname, @superclass
      @structklass = BuilderHelper.get_or_define_class @klass, :Struct, FFI::Struct
    end

    def setup_class
      setup_layout
      setup_constants
      alias_instance_methods
    end

    def setup_layout
      spec = layout_specification
      @structklass.class_eval { layout(*spec) }
    end

    def layout_specification
      if @info.fields.empty?
	if @parent
	  return [:parent, @superclass.const_get(:Struct), 0]
	end
      end
      spec = []
      @info.fields.each do |f|
	spec << f.name.to_sym
	spec << itypeinfo_to_ffitype_for_struct(f.type)
	spec << f.offset
      end
      spec
    end

    def itypeinfo_to_ffitype_for_struct typeinfo
      ffitype = Builder.itypeinfo_to_ffitype typeinfo
      if ffitype.kind_of?(Class) and BuilderHelper.const_defined_for ffitype, :Struct
	ffitype = ffitype.const_get :Struct
      end
      ffitype
    end

    def alias_instance_methods
      @info.methods.each do |m|
	@klass.class_eval "
	  def #{m.name} *args, &block
	    method_missing :#{m.name}, *args, &block
	  end
	"
      end
    end

    def setup_constants
      @klass.const_set :GIR_INFO, @info
      @klass.const_set :GIR_FFI_BUILDER, self
    end

    def instance_method_missing_definition
      InstanceMethodMissingDefinitionBuilder.new(@lib, @module, @namespace, @classname).generate
    end

    def class_method_missing_definition
      ClassMethodMissingDefinitionBuilder.new(@lib, @module, @namespace, @classname).generate
    end

    def already_set_up
      BuilderHelper.const_defined_for @klass, :GIR_FFI_BUILDER
    end

    def method_introspection_data method
      gir = IRepository.default
      objectinfo = gir.find_by_name @namespace, @classname
      return objectinfo.find_method method
    end

    def function_definition info, libmodule
      if info.constructor?
	fdbuilder = ConstructorDefinitionBuilder.new info, libmodule
      else
	fdbuilder = FunctionDefinitionBuilder.new info, libmodule
      end
      fdbuilder.generate
    end

    def prepare_method method
      go = method_introspection_data method

      return nil if go.nil?
      return nil if go.type != :function

      klass = build_class
      modul = @module
      lib = modul.const_get(:Lib)

      Builder.attach_ffi_function lib, go
      function_definition(go, lib)
    end

  end
end
