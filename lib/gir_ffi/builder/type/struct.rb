require 'gir_ffi/builder/type/struct_based'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing a Struct.
      class Struct < StructBased
        private

        def setup_class
          super
          provide_constructor
        end
      end
    end
  end
end


