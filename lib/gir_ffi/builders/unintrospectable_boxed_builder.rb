# frozen_string_literal: true

require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/struct_like'

module GirFFI
  module Builders
    # Implements the creation of a class representing a boxed type for
    # which no data is found in the GIR.
    class UnintrospectableBoxedBuilder < RegisteredTypeBuilder
      include StructLike

      def klass
        @klass ||= TypeBuilder::CACHE[target_gtype] ||= Class.new(superclass)
      end

      def setup_class
        setup_layout
        setup_constants
      end

      def superclass
        BoxedBase
      end

      def layout_superclass
        GirFFI::Struct
      end
    end
  end
end
