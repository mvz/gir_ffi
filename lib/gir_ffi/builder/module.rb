require 'gir_ffi/builder_helper'
require 'gir_ffi/module_base'
require 'gir_ffi/builder/function'
require 'indentation'

module GirFFI
  # Builds a module based on information found in the introspection
  # repository.
  class Builder::Module
    include BuilderHelper

    def initialize namespace, version=nil
      @namespace = namespace
      @version = version
      # FIXME: Pass safe namespace as an argument
      @safe_namespace = @namespace.gsub(/^(.)/) { $1.upcase }
    end

    def generate
      build_module
    end

    def setup_method method
      go = function_introspection_data method.to_s

      return false if go.nil?

      modul = build_module
      lib = modul.const_get(:Lib)

      Builder.attach_ffi_function lib, go

      meta = (class << modul; self; end)
      meta.class_eval function_definition(go, lib)

      true
    end

    def build_namespaced_class classname
      info = gir.find_by_name @namespace, classname.to_s
      Builder.build_class info
    end

    def build_module
      unless defined? @module
        build_dependencies
        build_module_non_recursive
      end
      @module
    end

    def build_module_non_recursive
      unless defined? @module
        instantiate_module
        setup_lib_for_ffi
        setup_module unless already_set_up
      end
      @module
    end

    def pretty_print
      s = "module #{@safe_namespace}\n"
      gir.infos(@namespace).each do |info|
        s << sub_builder(info).pretty_print.indent
        s << "\n"
      end
      s << "end"
    end

    private

    def build_dependencies
      deps = gir.dependencies @namespace
      deps.each {|dep|
        name, version = dep.split '-'
        Builder.build_module_non_recursive name, version
      }
    end

    def instantiate_module
      @module = get_or_define_module ::Object, @safe_namespace
    end

    def setup_module
      @module.extend ModuleBase
      @module.const_set :GIR_FFI_BUILDER, self
    end

    def already_set_up
      @module.respond_to? :method_missing
    end

    def setup_lib_for_ffi
      @lib = get_or_define_module @module, :Lib

      unless (class << @lib; self.include? FFI::Library; end)
        @lib.extend FFI::Library
        @lib.ffi_lib_flags :global, :lazy
        libspec = gir.shared_library(@namespace)
        unless libspec.nil?
          @lib.ffi_lib(*libspec.split(/,/))
        end
      end

      optionally_define_constant(@lib, :CALLBACKS) { [] }
    end

    def sub_builder info
      if info.info_type == :function
        Builder::Function.new(info, libmodule)
      else
        Builder::Type.builder_for info
      end
    end

    def libmodule
      @module.const_get(:Lib)
    end

    def function_introspection_data function
      info = gir.find_by_name @namespace, function.to_s
      return nil if info.nil?
      info.info_type == :function ? info : nil
    end

    def function_definition info, libmodule
      Builder::Function.new(info, libmodule).generate
    end

    def gir
      unless defined? @gir
        @gir = GObjectIntrospection::IRepository.default
        @gir.require @namespace, @version
      end
      @gir
    end

    def get_or_define_module parent, name
      optionally_define_constant(parent, name) { Module.new }
    end

  end
end
