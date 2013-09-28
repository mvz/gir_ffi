require 'gir_ffi/type_base'

module GirFFI
  class CallbackBase < Proc
    extend TypeBase

    CALLBACKS = []

    def self.store_callback prc
      CALLBACKS << prc
    end

    # Create Callback from a Proc. Makes sure arguments are properly wrapped,
    # and the callback is stored to prevent garbage collection.
    def self.from prc
      wrap_in_callback_args_mapper(prc).tap do |cb|
        store_callback cb
      end
    end

    def self.wrap_in_callback_args_mapper prc
      return prc if FFI::Function === prc
      return nil if prc.nil?
      return self.new do |*args|
        self::Callback.call_with_argument_mapping(prc, *args)
      end
    end
  end
end
