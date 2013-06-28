module GLib
  load_class :Variant

  # Overrides for GVariant, GLib's variant data type.
  class Variant
    setup_instance_method :get_string

    def get_string_with_override
      get_string_without_override.first
    end

    alias get_string_without_override get_string
    alias get_string get_string_with_override
  end
end
