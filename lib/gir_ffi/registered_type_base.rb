require 'gir_ffi/type_base'

module GirFFI
  # Base module for generated registered GLib types (these are types that have a
  # GType).
  module RegisteredTypeBase
    include TypeBase

    # @deprecated Use #gtype. Will be removed in 0.8.0.
    def get_gtype
      gtype
    end

    def gtype
      self::G_TYPE
    end
  end
end
