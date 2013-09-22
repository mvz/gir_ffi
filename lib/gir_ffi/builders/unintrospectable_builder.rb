require 'gir_ffi/builders/object_builder'

module GirFFI
  module Builders
    # Implements the creation of a class representing an object type for
    # which no data is found in the GIR. Typically, these are created to
    # cast objects returned by a function that returns an interface.
    class UnintrospectableBuilder < ObjectBuilder
      def instantiate_class
        gtype = target_gtype
        TypeBuilder::CACHE[gtype] ||= Class.new(superclass)
        @klass = TypeBuilder::CACHE[gtype]
        @structklass = get_or_define_class @klass, :Struct, layout_superclass
        setup_class unless already_set_up
      end

      def setup_class
        setup_constants
        setup_layout
        setup_interfaces
        setup_gtype_getter
      end

      def setup_instance_method method
        false
      end

      private

      def signal_definers
        info.interfaces
      end
    end
  end
end
