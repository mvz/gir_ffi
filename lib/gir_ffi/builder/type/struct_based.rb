require 'gir_ffi/builder/type/registered_type'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing one of the types
      # whose C representation is a struct, i.e., :object, :struct, and
      # :interface.
      class StructBased < RegisteredType
      end
    end
  end
end
