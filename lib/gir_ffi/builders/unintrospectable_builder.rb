# frozen_string_literal: true

require 'gir_ffi/builders/object_builder'
require 'gir_ffi/unintrospectable_signal_info'

module GirFFI
  module Builders
    # Implements the creation of a class representing an object type for
    # which no data is found in the GIR. Typically, these are created to
    # cast objects returned by a function that returns an interface.
    class UnintrospectableBuilder < ObjectBuilder
      def klass
        @klass ||= TypeBuilder::CACHE[target_gtype] ||= Class.new(superclass)
      end

      def setup_class
        setup_constants
        setup_layout
        setup_interfaces
      end

      def setup_instance_method(_method)
        false
      end

      def find_signal(signal_name)
        info = super
        return info if info

        signal_id = GObject.signal_lookup signal_name, target_gtype
        return UnintrospectableSignalInfo.new(signal_id) unless signal_id.zero?
      end
    end
  end
end
