require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/builders/mapping_method_builder'

module GirFFI
  module Builders
    # Implements the creation of a signal module for handling a particular
    # signal. The type will be attached to the appropriate class.
    class SignalBuilder < BaseTypeBuilder
      def mapping_method_definition
        MappingMethodBuilder.new(@info).method_definition
      end
    end
  end
end
