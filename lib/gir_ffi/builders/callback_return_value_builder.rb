require 'gir_ffi/builders/return_value_builder'

module GirFFI
  module Builders
    class CallbackReturnValueBuilder < ReturnValueBuilder
      def needs_outgoing_parameter_conversion?
        specialized_type_tag == :enum || super
      end

      def post_conversion
        args = conversion_arguments callarg
        "#{argument_class_name}.from(#{args})"
      end
    end
  end
end
