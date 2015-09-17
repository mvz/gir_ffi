GObject.load_class :InitiallyUnowned

module GObject
  # Overrides for GInitiallyUnowned, GObject's base class for objects that
  # start with a floating reference.
  class InitiallyUnowned
    # Initializing method used in constructors. For InitiallyUnowned and
    # descendants, this needs to sink the object's floating reference.
    def store_pointer ptr
      super
      ::GObject::Lib.g_object_ref_sink ptr
    end
  end
end
