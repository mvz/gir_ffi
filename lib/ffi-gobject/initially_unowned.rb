module GObject
  load_class :InitiallyUnowned

  # Overrides for GInitiallyUnowned, GObject's base class for objects that
  # start with a floating reference.
  class InitiallyUnowned
    def self.constructor_wrap ptr
      super.tap {|obj| ::GObject.object_ref_sink obj}
    end
  end
end

