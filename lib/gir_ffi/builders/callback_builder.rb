require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/builders/mapping_method_builder'
require 'gir_ffi/callback_base'

module GirFFI
  module Builders
    # Implements the creation of a callback type. The type will be
    # attached to the appropriate namespace module, and will be defined
    # as a callback for FFI.
    class CallbackBuilder < BaseTypeBuilder
      def instantiate_class
        klass
      end

      def klass
        @klass ||= optionally_define_constant namespace_module, @classname do
          cb = lib.callback callback_sym, argument_types, return_type
          cb.instance_eval mapping_method_definition
          cb.extend CallbackBase
          cb
        end
      end

      def mapping_method_definition
        MappingMethodBuilder.for_callback(info.args, info.return_type).method_definition
      end

      def callback_sym
        @classname.to_sym
      end

      def argument_types
        @info.argument_ffi_types
      end

      def return_type
        @info.return_ffi_type
      end
    end
  end
end
