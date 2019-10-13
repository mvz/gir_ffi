# frozen_string_literal: true

require "gir_ffi/builders/base_type_builder"
require "gir_ffi/builders/marshalling_method_builder"

module GirFFI
  module Builders
    # Implements the creation of a closure class for handling a particular
    # signal. The type will be attached to the appropriate class.
    class SignalClosureBuilder < BaseTypeBuilder
      def setup_class
        setup_constants
        klass.class_eval marshaller_definition, __FILE__, __LINE__
      end

      def setup_method(_method)
        nil
      end

      def marshaller_definition
        MarshallingMethodBuilder.for_signal(info).method_definition
      end

      private

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
