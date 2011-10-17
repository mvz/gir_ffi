module GObject
  load_class :InitiallyUnowned

  class InitiallyUnowned
    def self.constructor_wrap ptr
      super.tap {|obj| ::GObject.object_ref_sink obj}
    end
  end
end

