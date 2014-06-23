require 'gir_ffi/builders/base_argument_builder'

module GirFFI
  module Builders
    # Implements argument processing for error handling arguments. These
    # arguments are not part of the introspected signature, but their
    # presence is indicated by the 'throws' attribute of the function.
    class ErrorArgumentBuilder < BaseArgumentBuilder
      def method_argument_name
        nil
      end

      def return_value_name
        nil
      end

      def pre_conversion
        [ "#{call_argument_name} = FFI::MemoryPointer.new(:pointer).write_pointer nil" ]
      end

      def post_conversion
        [ "GirFFI::ArgHelper.check_error(#{call_argument_name})" ]
      end
    end
  end
end
