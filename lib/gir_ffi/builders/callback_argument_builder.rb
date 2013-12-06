require 'gir_ffi/builders/return_value_builder'

module GirFFI
  module Builders
    # TODO: Make CallbackArgumentBuilder accept argument name
    # TODO: Fix name of #post method
    class CallbackArgumentBuilder < ReturnValueBuilder
      def needs_outgoing_parameter_conversion?
        specialized_type_tag == :enum || super
      end
    end
  end
end

