require 'gir_ffi/builders/enum_builder'
require 'gir_ffi/flags_base'

module GirFFI
  module Builders
    # Implements the creation of a flags type. The type will be
    # attached to the appropriate namespace module, and will be defined
    # as a bit_mask for FFI.
    class FlagsBuilder < EnumBuilder
      def setup_ffi_type
        optionally_define_constant klass, :BitMask do
          lib.bit_mask(enum_sym, value_spec)
        end
      end

      def value_spec
        info.values.map do|vinfo|
          val = GirFFI::ArgHelper.cast_uint32_to_int32(vinfo.value)
          { vinfo.name.to_sym => val }
        end.reduce(:merge)
      end

      def superclass
        FlagsBase
      end
    end
  end
end
