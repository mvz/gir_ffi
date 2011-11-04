require 'gir_ffi/builder/type/registered_type'
require 'gir_ffi/builder/type/with_layout'
require 'gir_ffi/builder/type/with_methods'

module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing union type. The
      # class will have a nested FFI::Union class to represent its C union.
      class Union < RegisteredType
        include WithMethods
        include WithLayout

        private

        def setup_class
          setup_layout
          setup_constants
          stub_methods
          setup_gtype_getter
          provide_constructor
        end

        def layout_superclass
          FFI::Union
        end
      end
    end
  end
end


