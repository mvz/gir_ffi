# frozen_string_literal: true
require 'gir_ffi/builders/base_return_value_builder'

module GirFFI
  module Builders
    # Implements post-conversion for initializer functions
    class InitializerReturnValueBuilder < BaseReturnValueBuilder
      def post_conversion
        ["store_pointer(#{capture_variable_name})"]
      end
    end
  end
end
