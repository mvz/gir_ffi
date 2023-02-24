# frozen_string_literal: true

GLib.load_class :Variant

module GLib
  # Overrides for GVariant, GLib's variant data type.
  class Variant
    setup_instance_method! "get_string"

    def get_string_with_override
      get_string_without_override.first
    end

    alias_method :get_string_without_override, :get_string
    alias_method :get_string, :get_string_with_override

    # Initializing method used in constructors. For Variant the constructing
    # functions all return floating references, so this is need to take full
    # ownership.
    #
    # Also see the documentation for g_variant_ref_sink.
    def store_pointer(ptr)
      Lib.g_variant_ref_sink ptr
      super
    end

    # For variants, wrap_copy does not do any copying.
    def self.wrap_copy(val)
      wrap(val)
    end
  end
end
