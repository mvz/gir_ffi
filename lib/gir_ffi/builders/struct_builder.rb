require 'gir_ffi/builders/boxed_builder'
require 'gir_ffi/struct_base'

module GirFFI
  module Builders
    # Implements the creation of a class representing a Struct.
    class StructBuilder < BoxedBuilder
      def layout_superclass
        FFI::Struct
      end

      private

      def superclass
        StructBase
      end
    end
  end
end
