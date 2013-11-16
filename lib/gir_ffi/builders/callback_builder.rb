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
        @callback ||= optionally_define_constant klass, :Callback do
          lib.callback callback_sym, argument_types, return_type
        end
        unless already_set_up
          setup_constants
          klass.class_eval mapping_method_definition
        end
        klass
      end

      def klass
        @klass ||= get_or_define_class namespace_module, @classname, CallbackBase
      end

      def mapping_method_definition
        MappingMethodBuilder.for_callback(info.args, info.return_type).method_definition
      end

      def callback_sym
        @classname.to_sym
      end

      def argument_types
        @argument_types ||= @info.argument_ffi_types
      end

      def return_type
        @return_type ||= @info.return_ffi_type
      end
    end
  end
end
