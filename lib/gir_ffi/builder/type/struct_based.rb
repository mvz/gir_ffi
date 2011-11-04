require 'gir_ffi/builder/type/registered_type'
require 'gir_ffi/builder/type/with_layout'
require 'gir_ffi/builder/type/with_methods'

module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing one of the types
      # whose C representation is a struct, i.e., :object and :struct.
      class StructBased < RegisteredType
        include WithMethods
        include WithLayout

        def pretty_print
          "class #{@classname}\nend"
        end

        private

        def setup_class
          setup_layout
          setup_constants
          stub_methods
          setup_gtype_getter
        end

        def layout_superclass
          FFI::Struct
        end
      end
    end
  end
end
