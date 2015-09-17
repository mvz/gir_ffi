require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/with_layout'

module GirFFI
  module Builders
    # Implements the creation of a class representing boxed types.
    class BoxedBuilder < RegisteredTypeBuilder
      include WithLayout

      private

      def setup_class
        setup_layout
        setup_constants
        stub_methods
        setup_field_accessors
        provide_constructor
      end

      def provide_constructor
        return if info.find_method 'new'

        # TODO: Provide both new and initialize
        (class << klass; self; end).class_eval do
          alias_method :new, :_allocate
        end
      end
    end
  end
end
