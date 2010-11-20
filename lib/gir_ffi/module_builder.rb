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
  end
end
