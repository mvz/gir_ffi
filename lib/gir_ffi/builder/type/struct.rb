require 'gir_ffi/builder/type/registered_type'
require 'gir_ffi/builder/type/with_layout'
require 'gir_ffi/builder/type/with_methods'
require 'gir_ffi/struct_base'

module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing a Struct.
      class Struct < RegisteredType
        include WithMethods
        include WithLayout

        private

        def setup_class
          setup_layout
          setup_constants
          stub_methods
          setup_gtype_getter
          setup_field_accessors
          provide_constructor
        end

        # FIXME: Private method only in subclass
        def layout_superclass
          GirFFI::Struct
        end

        def superclass
          StructBase
        end
      end
    end
  end
end


