module GirFFI
  # Specialized kind of Proc to be used for callback arguments.
  class Callback < Proc
    # Create Callback from a Proc. Makes sure arguments are properly wrapped,
    # and the callback is stored to prevent garbage collection.
    def self.from namespace, name, prc
      GirFFI::CallbackHelper.wrap_in_callback_args_mapper(namespace, name, prc).tap do |cb|
        GirFFI::CallbackHelper.store_callback cb
      end
    end
  end
end
