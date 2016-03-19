# frozen_string_literal: true
require 'gir_ffi/builders/with_layout'

module GirFFI
  module Builders
    # Implements base methods used by struct and union builders
    module StructLike
      include WithLayout

      def setup_class
        setup_layout
        setup_constants
        stub_methods
        setup_field_accessors
      end

      def setup_field_accessors
        fields.each do |finfo|
          FieldBuilder.new(finfo).build
        end
      end
    end
  end
end

