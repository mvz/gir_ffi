require 'gir_ffi/type_base'

module GirFFI
  module CallbackBase
    CALLBACKS = []

    def store_callback prc
      CALLBACKS << prc
    end

    def self.store_callback prc
      CALLBACKS << prc
    end

    # Create Callback from a Proc. Makes sure arguments are properly wrapped,
    # and the callback is stored to prevent garbage collection.
    def from prc
      wrap_in_callback_args_mapper(prc).tap do |cb|
        store_callback cb
      end
    end

    def wrap_in_callback_args_mapper prc
      return prc if FFI::Function === prc
      return nil if prc.nil?
      return Proc.new do |*args|
        call_with_argument_mapping(prc, *args)
      end
    end
  end
end
