require 'gir_ffi/builders/type_builder'
require 'gir_ffi/builders/module_builder'
require 'gir_ffi/builder_helper'
require 'gir_ffi/unintrospectable_type_info'

module GirFFI
  # Builds modules and classes based on information found in the
  # introspection repository. Call its build_module and build_class methods
  # to create the modules and classes used in your program.
  module Builder
    extend BuilderHelper

    def self.build_class info
      Builders::TypeBuilder.build(info)
    end

    def self.build_by_gtype gtype
      info = GObjectIntrospection::IRepository.default.find_by_gtype gtype
      info ||= UnintrospectableTypeInfo.new gtype

      build_class info
    end

    def self.build_module namespace, version = nil
      Builders::ModuleBuilder.new(namespace, version).generate
    end

    # TODO: Move elsewhere, perhaps to FunctionBuilder.
    def self.attach_ffi_function lib, info
      sym = info.symbol
      return if lib.method_defined? sym

      lib.attach_function sym, info.argument_ffi_types, info.return_ffi_type
    end
  end
end
