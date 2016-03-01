# frozen_string_literal: true
require 'gir_ffi/builders/base_return_value_builder'

module GirFFI
  module Builders
    # Implements post-conversion for initializer functions
    class InitializerReturnValueBuilder < BaseReturnValueBuilder
      def capture_variable_name
        @capture_variable_name ||= new_variable
      end

      def post_conversion
        ["store_pointer(#{capture_variable_name})"]
      end
    end
  end
end
