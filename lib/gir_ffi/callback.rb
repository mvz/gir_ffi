module GirFFI
  class Callback < Proc
    def self.from namespace, name, prc
      GirFFI::CallbackHelper.wrap_in_callback_args_mapper(namespace, name, prc).tap do |cb|
        GirFFI::CallbackHelper.store_callback cb
      end
    end
  end
end
