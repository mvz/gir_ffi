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
          potential_parent_type = fields.first.field_type
          if potential_parent_type.tag == :interface
            potential_parent_type.tag_or_class
          else
            StructBase
          end
        else
          StructBase
        end
      end
    end
  end
end
