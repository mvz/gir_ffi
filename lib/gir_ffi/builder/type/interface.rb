require 'gir_ffi/builder/type/registered_type'
require 'gir_ffi/builder/type/with_methods'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a module representing an Interface.
      class Interface < RegisteredType
        include WithMethods

        private

        # FIXME: The word 'class' is not really correct.
        def instantiate_class
          @klass = optionally_define_constant(namespace_module, @classname) do
            ::Module.new do
              def self._builder
                const_get :GIR_FFI_BUILDER
              end
            end
          end
          setup_module unless already_set_up
        end

        def setup_module
          setup_constants
          stub_methods
        end
      end
    end
  end
end

