require 'gir_ffi/builder_helper'
require 'gir_ffi/module_base'

module GirFFI
  # Builds a module based on information found in the introspection
  # repository.
  class ModuleBuilder
    include BuilderHelper

    def initialize namespace
      @namespace = namespace
    end

    def generate
      build_module
    end

    def setup_function method
      go = function_introspection_data method.to_s

      return false if go.nil?

      modul = build_module
      lib = modul.const_get(:Lib)

      Builder.attach_ffi_function lib, go

      meta = (class << modul; self; end)
      meta.class_eval function_definition(go, lib)

      true
    end

    def build_class classname
      Builder.build_class @namespace, classname.to_s
    end

    private

    def build_module
      unless defined? @module
	instantiate_module
	setup_lib_for_ffi
	setup_module unless already_set_up
      end
      @module
    end

    def instantiate_module
      @module = get_or_define_module ::Object, @namespace.to_s
    end

    def setup_module
      @module.extend ModuleBase
      @module.const_set :GIR_FFI_BUILDER, self
      begin
	require "gir_ffi/overrides/#{@namespace.downcase}"
	@module.class_eval "include GirFFI::Overrides::#{@namespace}"
      rescue LoadError
      end
    end

    def already_set_up
      @module.respond_to? :method_missing
    end

    def setup_lib_for_ffi
      @lib = get_or_define_module @module, :Lib

      unless (class << @lib; self.include? FFI::Library; end)
	@lib.extend FFI::Library
	libs = gir.shared_library(@namespace).split(/,/)
	@lib.ffi_lib_flags :global, :lazy
	@lib.ffi_lib(*libs)
      end

      optionally_define_constant(@lib, :CALLBACKS) { [] }
    end

    def function_introspection_data function
      info = gir.find_by_name @namespace, function.to_s

      if info.type == :function
	info
      else
	nil
      end
    end

    def function_definition info, libmodule
      FunctionDefinitionBuilder.new(info, libmodule).generate
    end

    def gir
      unless defined? @gir
	@gir = IRepository.default
	@gir.require @namespace, nil
      end
      @gir
    end

    def get_or_define_module parent, name
      optionally_define_constant(parent, name) { Module.new }
    end

  end
end
