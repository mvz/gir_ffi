module GirFFI
  # Base class for all generated classes of type :object.
  class ObjectBase < ClassBase
    #
    # Wraps a pointer retrieved from a constructor method. Here, it is simply
    # defined as a wrapper around direct_wrap, but, e.g., InitiallyUnowned
    # overrides it to sink the floating object.
    #
    # Unlike wrap, this method assumes the pointer will always be of the type
    # corresponding to the current class, and never of a subtype.
    #
    # @param ptr Pointer to the object's C structure
    #
    # @return An object of the current class wrapping the pointer
    #
    def self.constructor_wrap ptr
      direct_wrap ptr
    end

    # Wrap the passed pointer in an instance of its type's corresponding class,
    # generally assumed to be a descendant of the current type.
    def self.wrap ptr
      ptr.to_object
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
