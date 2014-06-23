require 'gir_ffi/builders/base_argument_builder'

module GirFFI
  module Builders
    # Implements argument processing for error handling arguments. These
    # arguments are not part of the introspected signature, but their
    # presence is indicated by the 'throws' attribute of the function.
    class ErrorArgumentBuilder < BaseArgumentBuilder
      def pre_conversion
        [ "#{callarg} = FFI::MemoryPointer.new(:pointer).write_pointer nil" ]
      end

      def post
        [ "GirFFI::ArgHelper.check_error(#{callarg})" ]
      end
    end
  end
end
