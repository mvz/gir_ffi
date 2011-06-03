require 'gir_ffi/builder/type/registered_type'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing union type. The
      # class will have a nested FFI::Union class to represent its C union.
      class Union < RegisteredType
        def instantiate_class
          @klass = get_or_define_class namespace_module, @classname, superclass
          @structklass = get_or_define_class @klass, :Struct, FFI::Union
          setup_class unless already_set_up
        end

        def setup_class
          super
          provide_constructor
        end
      end
    end
  end
end


