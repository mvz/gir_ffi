require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/with_methods'
require 'gir_ffi/interface_base'

module GirFFI
  module Builders
    # Implements the creation of a module representing an Interface.
    class InterfaceBuilder < RegisteredTypeBuilder
      include WithMethods

      def interface_struct
        @interface_struct ||= Builder.build_class iface_struct_info
      end

      private

      # FIXME: The word 'class' is not really correct.
      def instantiate_class
        klass
        setup_module unless already_set_up
      end

      def klass
        @klass ||= get_or_define_module namespace_module, @classname
      end

      def setup_module
        klass.extend InterfaceBase
        setup_constants
        stub_methods
        setup_gtype_getter
      end

      def iface_struct_info
        @iface_struct_info ||= info.iface_struct
      end
    end
  end
end
