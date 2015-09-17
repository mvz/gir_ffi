require 'gir_ffi/builders/callback_builder'
require 'gir_ffi/builders/constant_builder'
require 'gir_ffi/builders/enum_builder'
require 'gir_ffi/builders/interface_builder'
require 'gir_ffi/builders/object_builder'
require 'gir_ffi/builders/struct_builder'
require 'gir_ffi/builders/signal_closure_builder'
require 'gir_ffi/builders/unintrospectable_builder'
require 'gir_ffi/builders/union_builder'
require 'gir_ffi/builders/vfunc_builder'

module GirFFI
  module Builders
    # Builds a class based on information found in the introspection
    # repository.
    module TypeBuilder
      CACHE = {}

      TYPE_MAP = {
        callback:         CallbackBuilder,
        constant:         ConstantBuilder,
        enum:             EnumBuilder,
        flags:            EnumBuilder,
        interface:        InterfaceBuilder,
        object:           ObjectBuilder,
        struct:           StructBuilder,
        union:            UnionBuilder,
        unintrospectable: UnintrospectableBuilder
      }

      def self.build(info)
        builder_for(info).build_class
      end

      # TODO: Pull up to include :function and :module
      def self.builder_for(info)
        TYPE_MAP[info.info_type].new(info)
      end
    end
  end
end
