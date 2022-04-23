# frozen_string_literal: true

GObject::Object.class_struct

module GObject
  # Overrides for GObjectClass, the class struct for GObject::Object
  class ObjectClass
    def set_property=(callback)
      struct[:set_property] = GObject::ObjectSetPropertyFunc.from callback
    end

    def get_property=(callback)
      struct[:get_property] = GObject::ObjectGetPropertyFunc.from callback
    end

    def gtype
      to_ptr.get_gtype 0
    end
  end
end
