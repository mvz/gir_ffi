# frozen_string_literal: true

require 'gir_ffi/builders/return_value_builder'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values of
    # property getters.
    class PropertyReturnValueBuilder < ReturnValueBuilder
      def needs_c_to_ruby_conversion?
        type_info.needs_c_to_ruby_conversion_for_properties?
      end
    end
  end
end
