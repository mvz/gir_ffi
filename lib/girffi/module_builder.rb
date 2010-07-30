module GirFFI
  class ModuleBuilder
    def initialize namespace, box
      @namespace = namespace
      @box = box
    end

    def generate
      build_module @namespace, @box
    end

    def build_module namespace, box=nil
      IRepository.default.require namespace, nil
      modul = setup_module namespace, box
      lb = setup_lib_for_ffi namespace, modul
      unless modul.respond_to? :method_missing
	modul.class_eval module_method_missing_definition lb, namespace
	modul.class_eval const_missing_definition namespace, box
      end
      modul
    end

    def setup_module namespace, box=nil
      if box.nil?
	boxm = ::Object
      else
	boxm = get_or_define_module ::Object, box.to_s
      end
      return get_or_define_module boxm, namespace.to_s
    end

    def setup_lib_for_ffi namespace, modul
      lb = get_or_define_module modul, :Lib

      unless (class << lb; self.include? FFI::Library; end)
	lb.extend FFI::Library
	libs = IRepository.default.shared_library(namespace).split(/,/)
	lb.ffi_lib(*libs)
      end

      GirFFI::BuilderHelper.optionally_define_constant(lb, :CALLBACKS) { [] }

      return lb
    end

    def module_method_missing_definition lib, namespace
      ModuleMethodMissingDefinitionBuilder.new(lib, namespace).generate
    end

    def const_missing_definition namespace, box=nil
      box = box.nil? ? "nil" : "\"#{box}\""
      return <<-CODE
	def self.const_missing classname
	  info = IRepository.default.find_by_name "#{namespace}", classname.to_s
	  return super if info.nil?
	  return GirFFI::Builder.build_class "#{namespace}", classname.to_s, #{box}
	end
      CODE
    end

    def get_or_define_module parent, name
      GirFFI::BuilderHelper.optionally_define_constant(parent, name) { Module.new }
    end

  end
end
