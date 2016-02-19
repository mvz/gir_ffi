# frozen_string_literal: true
require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/builders/marshalling_method_builder'

module GirFFI
  module Builders
    # Implements the creation of a closure class for handling a particular
    # signal. The type will be attached to the appropriate class.
    class SignalClosureBuilder < BaseTypeBuilder
      def setup_class
        setup_constants
        klass.class_eval marshaller_definition
      end

      def setup_method(_method)
        nil
      end

      def marshaller_definition
        container_type_info = ReceiverTypeInfo.new(container_info)
        receiver_info = ReceiverArgumentInfo.new(container_type_info)

        MarshallingMethodBuilder.for_signal(receiver_info,
                                            info).method_definition
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
