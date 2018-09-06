# frozen_string_literal: true

GObject.load_class :Closure

module GObject
  # Overrides for GClosure, GObject's base class for closure objects.
  #
  # To create Closure objects wrapping Ruby code, use {RubyClosure}.
  class Closure
    setup_method! :new_simple
    setup_instance_method! :invoke

    # @override
    #
    # @param [Proc] marshal The marshaller to use for this closure object
    def set_marshal(marshal)
      callback = ClosureMarshal.from marshal
      Lib.g_closure_set_marshal self, callback
    end

    # @override
    #
    # This override of invoke ensures the return value location can be passed
    # in as the first argument, which is needed to ensure the GValue is
    # initialized with the proper type.
    #
    # @param [GObject::Value] return_value The GValue to store the return
    #   value, or nil if no return value is expected.
    # @param [Array] param_values the closure parameters.
    def invoke(return_value, param_values)
      rval = Value.from(return_value)
      n_params = param_values.length
      params = GirFFI::SizedArray.from(Value, -1, param_values)
      Lib.g_closure_invoke self, rval, n_params, params, nil
      rval.get_value
    end

    def store_pointer(ptr)
      # NOTE: Call C functions directly to avoid extra argument conversion
      Lib.g_closure_ref ptr
      Lib.g_closure_sink ptr
      super
    end
  end
end
