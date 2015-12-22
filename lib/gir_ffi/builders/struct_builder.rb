require 'gir_ffi/builders/boxed_builder'
require 'gir_ffi/struct_base'

module GirFFI
  module Builders
    # Implements the creation of a class representing a Struct.
    class StructBuilder < BoxedBuilder
      def layout_superclass
        FFI::Struct
      end

      def superclass
        if info.gtype_struct?
          type = fields.first.field_type
          return type.tag_or_class if type.tag == :interface
        end

        StructBase
      end
    end
  end
end
