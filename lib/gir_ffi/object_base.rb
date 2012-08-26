module GirFFI
  # Base class for all generated classes of type :object.
  class ObjectBase < ClassBase
    #
    # Wraps a pointer retrieved from a constructor method. Here,
    # it is simply defined as a wrapper around wrap, but, e.g., InitiallyUnowned
    # overrides it to sink the floating object.
    #
    # @param ptr Pointer to the object's C structure
    #
    # @return An object of the current class wrapping the pointer
    #
    def self.constructor_wrap ptr
      wrap ptr
    end

    #
    # Find property info for the named property.
    #
    # @param name The property's name
    #
    # @return [GObjectIntrospection::IPropertyInfo] The property's info
    #
    def self.find_property name
      gir_ffi_builder.find_property name
    end

    #
    # Find signal info for the named signal.
    #
    # @param name The signal's name
    #
    # @return [GObjectIntrospection::ISignalInfo] The signal's info
    #
    def self.find_signal name
      gir_ffi_builder.find_signal name
    end
  end
end
