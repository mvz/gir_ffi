# frozen_string_literal: true

require 'gir_ffi/builders/base_type_builder'
module GirFFI
  module Builders
    # Implements the creation of a constant. Though semantically not a
    # type, its build method is like that of the types, in that it is
    # triggered by a missing constant in the parent namespace.  The
    # constant will be attached to the appropriate namespace module.
    class ConstantBuilder < BaseTypeBuilder
      def build_class
        @klass ||= optionally_define_constant namespace_module, @classname do
          info.value
        end
      end
    end
  end
end
