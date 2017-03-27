# frozen_string_literal: true

require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/struct_like'
require 'gir_ffi/union_base'
require 'gir_ffi/union'

module GirFFI
  module Builders
    # Implements the creation of a class representing union type. The
    # class will have a nested GirFFI::Union class to represent its C union.
    class UnionBuilder < RegisteredTypeBuilder
      include StructLike

      def layout_superclass
        GirFFI::Union
      end

      private

      def superclass
        UnionBase
      end
    end
  end
end
