require 'gir_ffi/builders/callback_argument_builder'

module GirFFI
  module Builders
    # Convertor for arguments for vfuncs. Used when building the
    # argument mapper for vfuncs.
    class VFuncArgumentBuilder < CallbackArgumentBuilder
      def pre_conversion
        if direction == :in && ownership_transfer == :nothing && specialized_type_tag == :object
          super + [pre_ref_count_increase]
        else
          super
        end
      end

      private

      def pre_ref_count_increase
        "#{pre_converted_name}.ref"
      end

      # SMELL: Override private method
      def post_convertor_argument
        if direction == :out && ownership_transfer == :everything && specialized_type_tag == :object
          "#{super}.ref"
        else
          super
        end
      end
    end
  end
end
