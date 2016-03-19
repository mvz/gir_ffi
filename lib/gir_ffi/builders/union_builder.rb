# frozen_string_literal: true
require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/struct_like'
require 'gir_ffi/union_base'

module GirFFI
  module Builders
    # Implements the creation of a class representing union type. The
    # class will have a nested FFI::Union class to represent its C union.
    class UnionBuilder < RegisteredTypeBuilder
      include StructLike

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
