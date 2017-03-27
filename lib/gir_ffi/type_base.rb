# frozen_string_literal: true

module GirFFI
  # Base module for all generated GLib types.
  module TypeBase
    def gir_ffi_builder
      self::GIR_FFI_BUILDER
    end

    def gir_info
      self::GIR_INFO
    end
  end
end
