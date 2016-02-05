# frozen_string_literal: true
require 'gir_ffi/builders/callback_argument_builder'

module GirFFI
  module Builders
    # Convertor for arguments for RubyClosure objects. Used when building the
    # marshaller for signal handler closures.
    class ClosureArgumentBuilder < CallbackArgumentBuilder
      def needs_c_to_ruby_conversion?
        type_info.needs_c_to_ruby_conversion_for_closures?
      end
    end
  end
end
