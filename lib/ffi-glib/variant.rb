GLib.load_class :Variant

module GLib
  # Overrides for GVariant, GLib's variant data type.
  class Variant
    setup_instance_method "get_string"

    def get_string_with_override
      get_string_without_override.first
    end

    def self.constructor_wrap ptr
      super.tap(&:ref)
    end

    alias_method :get_string_without_override, :get_string
    alias_method :get_string, :get_string_with_override
  end
end
