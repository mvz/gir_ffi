require 'gir_ffi/builders/boxed_builder'

module GirFFI
  module Builders
    # Implements the creation of a class representing a boxed type for
    # which no data is found in the GIR.
    class UnintrospectableBoxedBuilder < BoxedBuilder
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
        FFI::Struct
      end
    end
  end
end

