require 'gir_ffi/builder/type/registered_type'
require 'gir_ffi/builder/type/with_methods'
require 'gir_ffi/interface_base'

module GirFFI
  module Builder
    module Type

      # Implements the creation of a module representing an Interface.
      class Interface < RegisteredType
        include WithMethods

        def pretty_print
          "module #{@classname}\n  extend InterfaceBase\nend"
        end

        private

        # FIXME: The word 'class' is not really correct.
        def instantiate_class
          @klass = optionally_define_constant(namespace_module, @classname) do
            ::Module.new
          end
          setup_module unless already_set_up
        end

        def setup_module
          @klass.extend InterfaceBase
          setup_constants
          stub_methods
          setup_gtype_getter
        end
      end
    end
  end
end

