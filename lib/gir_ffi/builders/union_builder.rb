require 'gir_ffi/builders/boxed_builder'
require 'gir_ffi/union_base'

module GirFFI
  module Builders
    # Implements the creation of a class representing union type. The
    # class will have a nested FFI::Union class to represent its C union.
    class UnionBuilder < BoxedBuilder
      def layout_superclass
        FFI::Union
      end

      private

      def superclass
        UnionBase
      end
    end
  end
end
