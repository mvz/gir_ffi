require 'gir_ffi/builder/type/struct_based'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing an Interface.
      class Interface < RegisteredType
        def build_class
          unless defined? @klass
            instantiate_module
          end
          @klass
        end

        def instantiate_module
          @klass = optionally_define_constant(namespace_module, @classname) {
            ::Module.new
          }
        end
      end
    end
  end
end

