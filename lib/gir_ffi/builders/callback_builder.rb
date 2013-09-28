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
        @klass ||= get_or_define_class namespace_module, @classname, OldCallbackBase
        @callback ||= optionally_define_constant @klass, :Callback do
          cb = lib.callback callback_sym, argument_types, return_type
          cb.instance_eval mapping_method_definition
          cb.extend CallbackBase
          cb
        end
        unless already_set_up
          setup_constants
          @klass.class_eval mapping_method_definition
        end
        @klass
      end

      def mapping_method_definition
        MappingMethodBuilder.new(info.args, info.return_type).method_definition
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
