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

        def instantiate_class
          @klass = get_or_define_class namespace_module, @classname, superclass
          @structklass = get_or_define_class @klass, :Struct, FFI::Union
          setup_class unless already_set_up
        end
      end
    end
  end
end


