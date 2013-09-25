require 'gir_ffi/builders/base_type_builder'

module GirFFI
  module Builders
    # Implements the creation of a signal module for handling a particular
    # signal. The type will be attached to the appropriate class.
    class SignalBuilder < BaseTypeBuilder
      def mapping_method_definition
        code = "def self.call_with_argument_mapping(_proc)"
        code << "\n  _proc.call()"
        code << "\nend\n"
        code
      end
    end
  end
end
