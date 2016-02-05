# frozen_string_literal: true
require 'gir_ffi/builders/callback_argument_builder'

module GirFFI
  module Builders
    # Convertor for arguments for vfuncs. Used when building the
    # argument mapper for vfuncs.
    class VFuncArgumentBuilder < CallbackArgumentBuilder
      def pre_conversion
        if ingoing_ref_needed
          super + [pre_ref_count_increase]
        else
          super
        end
      end

      private

      def ingoing_ref_needed
        direction == :in &&
          ownership_transfer == :nothing &&
          specialized_type_tag == :object
      end

      def pre_ref_count_increase
        "#{pre_converted_name}.ref"
      end

      # SMELL: Override private method
      def post_convertor_argument
        if outgoing_ref_needed
          "#{super}.ref"
        else
          super
        end
      end

      def outgoing_ref_needed
        direction == :out &&
          ownership_transfer == :everything &&
          specialized_type_tag == :object
      end
    end
  end
end
