require 'gir_ffi/builder/type/registered_type'
require 'gir_ffi/builder/type/with_layout'
require 'gir_ffi/builder/type/with_methods'

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
          FFI::Struct
        end
      end
    end
  end
end


