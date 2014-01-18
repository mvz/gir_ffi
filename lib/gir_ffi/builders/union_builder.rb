require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/with_layout'
require 'gir_ffi/builders/with_methods'
require 'gir_ffi/union_base'

module GirFFI
  module Builders
    # Implements the creation of a class representing union type. The
    # class will have a nested FFI::Union class to represent its C union.
    class UnionBuilder < RegisteredTypeBuilder
      include WithMethods
      include WithLayout

      def layout_superclass
        FFI::Union
      end

      private

      def setup_class
        setup_layout
        setup_constants
        stub_methods
        setup_field_accessors
        provide_constructor
      end

      def superclass
        UnionBase
      end
    end
  end
end
