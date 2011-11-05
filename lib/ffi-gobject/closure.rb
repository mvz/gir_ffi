module GObject
  load_class :Closure

  # Overrides for GClosure, GObject's base class for closure objects.
  class Closure
    def set_marshal marshal
      _v1 = GirFFI::CallbackHelper.wrap_in_callback_args_mapper(
        "GObject", "ClosureMarshal", marshal)
        ::GObject::Lib::CALLBACKS << _v1
        ::GObject::Lib.g_closure_set_marshal self, _v1
    end
  end
end
