GObject.load_class :ObjectClass

module GObject
  # Overrides for GObjectClass, a struct containing GObject's class data
  class ObjectClass
    def set_property=(callback)
      @struct[:set_property] = GObject::ObjectSetPropertyFunc.from callback
    end

    def get_property=(callback)
      @struct[:get_property] = GObject::ObjectGetPropertyFunc.from callback
    end

    def gtype
      GirFFI::InOutPointer.new(:GType, to_ptr).to_value
    end

    def self.for_gtype(gtype)
      type_class = GObject::TypeClass.ref gtype
      wrap(type_class.to_ptr)
    end
  end
end
