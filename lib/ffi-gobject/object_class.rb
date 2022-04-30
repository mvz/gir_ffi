# frozen_string_literal: true

GObject::Object.class_struct

module GObject
  # Overrides for GObjectClass, the class struct for GObject::Object
  class ObjectClass
    def gtype
      to_ptr.get_gtype 0
    end
  end
end
