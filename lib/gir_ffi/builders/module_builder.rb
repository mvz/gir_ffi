require 'gir_ffi/builder_helper'
require 'gir_ffi/module_base'
require 'gir_ffi/builders/function_builder'
require 'indentation'

module GirFFI
  module Builders
    # Builds a module based on information found in the introspection
    # repository.
    class ModuleBuilder
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

        Builder.attach_ffi_function libmodule, go
        definition = function_definition go
        modul.class_eval definition

        true
      end

      def build_namespaced_class classname
        info = gir.find_by_name @namespace, classname.to_s
        if info.nil?
          raise NameError.new(
            "Class #{classname} not found in namespace #{@namespace}")
        end
        Builder.build_class info
      end

      def build_module
        unless defined? @module
          build_dependencies
          instantiate_module
          setup_lib_for_ffi unless lib_already_set_up
          setup_module unless already_set_up
        end
        @module
      end

      private

      def build_dependencies
        deps = gir.dependencies @namespace
        deps.each {|dep|
          name, version = dep.split '-'
          Builder.build_module name, version
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
        lib.extend FFI::Library
        lib.ffi_lib_flags :global, :lazy
        if shared_library_specification
          lib.ffi_lib(*shared_library_specification.split(/,/))
        end
      end

      def shared_library_specification
        @shared_library_specification ||= gir.shared_library(@namespace)
      end

      def lib_already_set_up
        (class << lib; self; end).include? FFI::Library
      end

      def lib
        @lib ||= get_or_define_module @module, :Lib
      end

      def libmodule
        @module.const_get(:Lib)
      end

      def function_introspection_data function
        info = gir.find_by_name @namespace, function.to_s
        return nil if info.nil?
        info.info_type == :function ? info : nil
      end

      def function_definition info
        FunctionBuilder.new(info).generate
      end

      def gir
        unless defined? @gir
          @gir = GObjectIntrospection::IRepository.default
          @gir.require @namespace, @version
        end
        @gir
      end
    end
  end
end
