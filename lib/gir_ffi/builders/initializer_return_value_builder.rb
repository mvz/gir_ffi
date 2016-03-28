# frozen_string_literal: true
require 'gir_ffi/builders/base_return_value_builder'

module GirFFI
  module Builders
    # Implements post-conversion for initializer functions
    class InitializerReturnValueBuilder < BaseReturnValueBuilder
      def post_conversion
        result = []
        result << "store_pointer(#{capture_variable_name})"
        if specialized_type_tag == :struct
          result << '@struct.owned = true'
        end
        result
      end
    end
  end
end
