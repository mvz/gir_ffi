require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/builders/mapping_method_builder'
require 'gir_ffi/callback_base'

module GirFFI
  module Builders
    # Implements the creation of a callback type. The type will be
    # attached to the appropriate namespace module, and will be defined
    # as a callback for FFI.
    class CallbackBuilder < BaseTypeBuilder
      def setup_class
        setup_callback
        setup_constants
        klass.class_eval mapping_method_definition
      end

      def setup_callback
        optionally_define_constant klass, :Callback do
          lib.callback callback_sym, argument_ffi_types, return_ffi_type
        end
      end

      def klass
        @klass ||= get_or_define_class namespace_module, @classname, CallbackBase
      end

      def mapping_method_definition
        return_value_info = ReturnValueInfo.new(info.return_type,
                                                info.caller_owns,
                                                info.skip_return?)
        MappingMethodBuilder.for_callback(info.args,
                                          return_value_info).method_definition
      end

      def callback_sym
        @classname.to_sym
      end

      def argument_ffi_types
        @argument_ffi_types ||= @info.argument_ffi_types
      end

      def return_ffi_type
        @return_ffi_type ||= @info.return_ffi_type
      end
    end
  end
end
