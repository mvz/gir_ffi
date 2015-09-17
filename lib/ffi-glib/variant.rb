GLib.load_class :Variant

module GLib
  # Overrides for GVariant, GLib's variant data type.
  class Variant
    setup_instance_method 'get_string'

    def get_string_with_override
      get_string_without_override.first
    end

    # Initializing method used in constructors. For Variant, this needs to sink
    # the variant's floating reference.
    #
    # NOTE: This is very hard to test since it is not possible to get the
    # variant's ref count directely. However, there is an error when running
    # the tests on 32-bit systems.
    def store_pointer(ptr)
      super
      ::GLib::Lib.g_variant_ref_sink ptr
    end

    alias_method :get_string_without_override, :get_string
    alias_method :get_string, :get_string_with_override
  end
end
