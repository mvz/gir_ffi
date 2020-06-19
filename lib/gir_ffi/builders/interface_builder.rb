# frozen_string_literal: true

require "gir_ffi/builders/registered_type_builder"
require "gir_ffi/interface_base"

module GirFFI
  module Builders
    # Implements the creation of a module representing an Interface.
    class InterfaceBuilder < RegisteredTypeBuilder
      def interface_struct
        @interface_struct ||=
          ClassStructBuilder.new(iface_struct_info,
                                 GObject::TypeInterface).build_class
      end

      private

      def klass
        @klass ||= get_or_define_module namespace_module, @classname
      end

      # FIXME: The word 'class' is not really correct.
      def setup_class
        klass.extend InterfaceBase
        setup_constants
        stub_methods
      end

      def iface_struct_info
        @iface_struct_info ||= info.iface_struct
      end
    end
  end
end
