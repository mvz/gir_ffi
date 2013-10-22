require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/with_methods'
require 'gir_ffi/interface_base'

module GirFFI
  module Builders
    # Implements the creation of a module representing an Interface.
    class InterfaceBuilder < RegisteredTypeBuilder
      include WithMethods

      private

      # FIXME: The word 'class' is not really correct.
      def instantiate_class
        klass
        setup_module unless already_set_up
      end

      def klass
        @klass ||= optionally_define_constant(namespace_module, @classname) do
          ::Module.new
        end
      end

      def setup_module
        klass.extend InterfaceBase
        setup_constants
        stub_methods
        setup_gtype_getter
      end
    end
  end
end
