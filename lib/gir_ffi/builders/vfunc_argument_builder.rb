# frozen_string_literal: true
require 'gir_ffi/builders/callback_argument_builder'

module GirFFI
  module Builders
    # Convertor for arguments for vfuncs. Used when building the
    # argument mapper for vfuncs.
    class VFuncArgumentBuilder < CallbackArgumentBuilder
      def pre_conversion
        if ingoing_ref_needed?
          super + ["#{pre_converted_name}.ref"]
        else
          super
        end
      end

      def post_conversion
        if outgoing_ref_needed?
          ["#{result_name}.ref"] + super
        else
          super
        end
      end

      private

      def ingoing_ref_needed?
        direction == :in &&
          ownership_transfer == :nothing &&
          specialized_type_tag == :object
      end

      def outgoing_ref_needed?
        direction == :out &&
          ownership_transfer == :everything &&
          specialized_type_tag == :object
      end
    end
  end
end
