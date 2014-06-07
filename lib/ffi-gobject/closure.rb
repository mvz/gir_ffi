GObject.load_class :Closure

module GObject
  # Overrides for GClosure, GObject's base class for closure objects.
  class Closure
    def set_marshal marshal
      callback = GObject::ClosureMarshal.from marshal
      Lib.g_closure_set_marshal self, callback
    end
  end
end
