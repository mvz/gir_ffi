module GObject
  load_class :Closure

  # Overrides for GClosure, GObject's base class for closure objects.
  class Closure
    def set_marshal marshal
      callback = GirFFI::Callback.from("GObject", "ClosureMarshal", marshal)
      Lib.g_closure_set_marshal self, callback
    end
  end
end
