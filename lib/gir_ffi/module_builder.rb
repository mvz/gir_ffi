require 'gir_ffi/builder_helper'

module GirFFI
  # Builds a module based on information found in the introspection
  # repository.
  class ModuleBuilder

    def initialize namespace
      @namespace = namespace
    end

    def generate
      build_module
    end

    def setup_function method
      go = function_introspection_data method.to_s

      return false if go.nil?
      return false if go.type != :function

      modul = build_module
      lib = modul.const_get(:Lib)

      GirFFI::Builder.attach_ffi_function lib, go

      meta = (class << modul; self; end)
      meta.class_eval function_definition(go, lib)

      true
    end

    private

    def build_module
      IRepository.default.require @namespace, nil
      setup_module
      setup_lib_for_ffi
      unless @module.respond_to? :method_missing
	@module.class_eval module_method_missing_definition
	@module.class_eval const_missing_definition
	begin
	  require "gir_ffi/overrides/#{@namespace.downcase}"
	  @module.class_eval "include GirFFI::Overrides::#{@namespace}"
	rescue LoadError
	end
      end
      @module
    end

    def setup_module
      @module = BuilderHelper.get_or_define_module ::Object, @namespace.to_s
    end

    def setup_lib_for_ffi
      @lib = BuilderHelper.get_or_define_module @module, :Lib

      unless (class << @lib; self.include? FFI::Library; end)
	@lib.extend FFI::Library
	libs = IRepository.default.shared_library(@namespace).split(/,/)
	@lib.ffi_lib(*libs)
      end

      BuilderHelper.optionally_define_constant(@lib, :CALLBACKS) { [] }
    end

    def module_method_missing_definition
      ModuleMethodMissingDefinitionBuilder.new(@lib, @namespace).generate
    end

    def const_missing_definition
      return <<-CODE
	def self.const_missing classname
	  info = IRepository.default.find_by_name "#{@namespace}", classname.to_s
	  return super if info.nil?
	  return GirFFI::Builder.build_class "#{@namespace}", classname.to_s
	end
      CODE
    end

    def function_introspection_data function
      gir = IRepository.default
      return gir.find_by_name @namespace, function.to_s
    end

    def function_definition info, libmodule
      FunctionDefinitionBuilder.new(info, libmodule).generate
    end

  end
end
