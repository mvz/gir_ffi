# frozen_string_literal: true

GLib.load_class :Error

module GLib
  # Overrides for GError, used by GLib for handling non-fatal errors.
  class Error
    GIR_FFI_DOMAIN = GLib.quark_from_string('gir_ffi')

    def self.from_exception(exception)
      new_literal GIR_FFI_DOMAIN, 0, exception.message
    end

    def self.from(obj)
      from_exception obj
    end
  end
end
