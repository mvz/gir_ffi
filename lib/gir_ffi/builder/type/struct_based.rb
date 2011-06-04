require 'gir_ffi/builder/type/registered_type'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing one of the types
      # whose C representation is a struct, i.e., :object, :struct, and
      # :interface.
      class StructBased < RegisteredType
        def instantiate_class
          @klass = get_or_define_class namespace_module, @classname, superclass
          @structklass = get_or_define_class @klass, :Struct, FFI::Struct
          setup_class unless already_set_up
        end
      end
    end
  end
end
