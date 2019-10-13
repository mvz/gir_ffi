# frozen_string_literal: true

require "gir_ffi/builders/type_builder"
require "gir_ffi/builders/module_builder"
require "gir_ffi/builder_helper"
require "gir_ffi/unintrospectable_type_info"
require "gir_ffi/unintrospectable_boxed_info"

module GirFFI
  # Builds modules and classes based on information found in the
  # introspection repository. Call its build_module and build_class methods
  # to create the modules and classes used in your program.
  module Builder
    extend BuilderHelper

    def self.build_class(info)
      Builders::TypeBuilder.build(info)
    end

    def self.build_by_gtype(gtype)
      info = GObjectIntrospection::IRepository.default.find_by_gtype gtype
      info ||= begin
                 fund = GObject.type_fundamental gtype
                 if fund == GObject::TYPE_BOXED
                   UnintrospectableBoxedInfo.new gtype
                 elsif fund == GObject::TYPE_OBJECT
                   UnintrospectableTypeInfo.new gtype
                 elsif fund >= GObject::TYPE_RESERVED_USER_FIRST
                   UnintrospectableTypeInfo.new gtype
                 else
                   raise "Unable to handle type #{GObject.type_name gtype}"
                 end
               end

      build_class info
    end

    def self.build_module(namespace, version = nil)
      module_name = namespace.sub(/\A./, &:upcase)
      if const_defined? module_name
        modul = const_get module_name
        unless modul.const_defined? :GIR_FFI_BUILDER
          raise "The module #{module_name} was already defined elsewhere"
        end
      end
      Builders::ModuleBuilder.new(module_name,
                                  namespace: namespace,
                                  version: version).generate
    end

    # TODO: Move elsewhere, perhaps to FunctionBuilder.
    def self.attach_ffi_function(lib, info)
      sym = info.symbol
      return if lib.method_defined? sym

      lib.attach_function sym, info.argument_ffi_types, info.return_ffi_type
    end
  end
end
