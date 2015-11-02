require 'gir_ffi/builders/callback_return_value_builder'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values of
    # closures.
    class ClosureReturnValueBuilder < CallbackReturnValueBuilder
      def needs_ruby_to_c_conversion?
        type_info.needs_ruby_to_c_conversion_for_closures?
      end
    end
  end
end

