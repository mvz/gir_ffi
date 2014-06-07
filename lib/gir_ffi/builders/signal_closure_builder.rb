require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/builders/marshalling_method_builder'

module GirFFI
  module Builders
    # Implements the creation of a closure class for handling a particular
    # signal. The type will be attached to the appropriate class.
    class SignalClosureBuilder < BaseTypeBuilder
      def instantiate_class
        unless already_set_up
          setup_constants
          klass.class_eval marshaller_definition
        end
        klass
      end

      def setup_method method
        nil
      end

      def marshaller_definition
        arg_infos = info.args

        container_type_info = ReceiverTypeInfo.new(container_info)
        receiver_info = ReceiverArgumentInfo.new(container_type_info)
        return_value_info = ReturnValueInfo.new info.return_type

        MarshallingMethodBuilder.for_signal(receiver_info,
                                            arg_infos,
                                            return_value_info).method_definition
      end

      def klass
        @klass ||= get_or_define_class container_class, @classname, GObject::RubyClosure
      end

      def container_class
        @container_class ||= Builder.build_class(container_info)
      end

      def container_info
        @container_info ||= info.container
      end
    end
  end
end

