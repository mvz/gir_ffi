# frozen_string_literal: true

require "gir_ffi/builder_helper"
require "gir_ffi/module_base"
require "gir_ffi/builders/function_builder"

module GirFFI
  module Builders
    # Builds a module based on information found in the introspection
    # repository.
    class ModuleBuilder
      include BuilderHelper

      def initialize(module_name, namespace: module_name, version: nil)
        @namespace = namespace
        @version = version
        @safe_namespace = module_name
      end

      def generate
        modul
      end

      def setup_method(method)
        go = function_introspection_data method.to_s
        return false unless go

        Builder.attach_ffi_function lib, go
        modul.class_eval FunctionBuilder.new(go).method_definition, __FILE__, __LINE__

        true
      end

      def method_available?(method)
        function_introspection_data(method.to_s) and true
      end

      def build_namespaced_class(classname)
        info = find_namespaced_class_info(classname)
        Builder.build_class info
      end

      def find_namespaced_class_info(classname)
        name = classname.to_s
        info = gir.find_by_name(@namespace, name) ||
          gir.find_by_name(@namespace, name.sub(/^./, &:downcase))
        unless info
          raise NameError,
                "Class #{classname} not found in namespace #{@namespace}"
        end
        info
      end

      private

      def modul
        unless defined? @module
          build_dependencies
          instantiate_module
          setup_lib_for_ffi unless lib_already_set_up
          setup_module unless already_set_up
        end
        @module
      end

      def build_dependencies
        deps = gir.dependencies @namespace
        deps.each do |dep|
          name, version = dep.split "-"
          Builder.build_module name, version
        end
      end

      def instantiate_module
        @module = get_or_define_module ::Object, @safe_namespace
      end

      def setup_module
        @module.extend ModuleBase
        @module.const_set :GIR_FFI_BUILDER, self
      end

      def already_set_up
        @module.const_defined? :GIR_FFI_BUILDER
      end

      def setup_lib_for_ffi
        lib.extend FFI::Library
        lib.extend FFI::BitMasks
        lib.ffi_lib_flags :global, :lazy
        lib.ffi_lib(*shared_library_specification.split(/,/)) if shared_library_specification
      end

      def shared_library_specification
        @shared_library_specification ||= gir.shared_library(@namespace)
      end

      def lib_already_set_up
        (class << lib; self; end).include? FFI::Library
      end

      def lib
        @lib ||= get_or_define_module modul, :Lib
      end

      def function_introspection_data(function)
        info = gir.find_by_name @namespace, function.to_s
        return unless info

        info.info_type == :function ? info : nil
      end

      def gir
        @gir ||= GObjectIntrospection::IRepository.default.tap do |it|
          it.require @namespace, @version
        end
      end
    end
  end
end
