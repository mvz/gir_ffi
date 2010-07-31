module GirFFI
  class ModuleBuilder
    def initialize namespace, box
      @namespace = namespace
      @box = box
    end

    def generate
      build_module
    end

    def build_module
      IRepository.default.require @namespace, nil
      setup_module
      setup_lib_for_ffi
      unless @module.respond_to? :method_missing
	@module.class_eval module_method_missing_definition
	@module.class_eval const_missing_definition
      end
      @module
    end

    def setup_module
      if @box.nil?
	boxm = ::Object
      else
	boxm = get_or_define_module ::Object, @box.to_s
      end
      @module = get_or_define_module boxm, @namespace.to_s
    end

    def setup_lib_for_ffi
      @lib = get_or_define_module @module, :Lib

      unless (class << @lib; self.include? FFI::Library; end)
	@lib.extend FFI::Library
	libs = IRepository.default.shared_library(@namespace).split(/,/)
	@lib.ffi_lib(*libs)
      end

      GirFFI::BuilderHelper.optionally_define_constant(@lib, :CALLBACKS) { [] }
    end

    def module_method_missing_definition
      ModuleMethodMissingDefinitionBuilder.new(@lib, @namespace).generate
    end

    def const_missing_definition
      box = @box.nil? ? "nil" : "\"#{@box}\""
      return <<-CODE
	def self.const_missing classname
	  info = IRepository.default.find_by_name "#{@namespace}", classname.to_s
	  return super if info.nil?
	  return GirFFI::Builder.build_class "#{@namespace}", classname.to_s, #{box}
	end
      CODE
    end

    def get_or_define_module parent, name
      GirFFI::BuilderHelper.optionally_define_constant(parent, name) { Module.new }
    end

  end
end
