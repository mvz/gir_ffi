module GLib
  load_class :Error

  class Error
    # TODO: Auto-convert strings and symbols to quarks
    GIR_FFI_DOMAIN = GLib.quark_from_string("gir_ffi")

    def self.from_exception ex
      new_literal GIR_FFI_DOMAIN, 0, ex.message
    end

    def self.from it
      from_exception it
    end
  end
end
