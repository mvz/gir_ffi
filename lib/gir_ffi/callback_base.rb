require 'gir_ffi/type_base'

module GirFFI
  class CallbackBase < Proc
    extend TypeBase

    # Create Callback from a Proc. Makes sure arguments are properly wrapped,
    # and the callback is stored to prevent garbage collection.
    def self.from prc
      wrap_in_callback_args_mapper(prc).tap do |cb|
        CallbackHelper.store_callback cb
      end
    end

    def self.wrap_in_callback_args_mapper prc
      return prc if FFI::Function === prc
      return nil if prc.nil?
      info = self.gir_info
      return self.new do |*args|
        prc.call(*GirFFI::Callback.map_callback_args(args, info))
      end
    end
  end
end
