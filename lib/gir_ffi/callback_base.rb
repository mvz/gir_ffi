require 'gir_ffi/type_base'

module GirFFI
  # Base module for callbacks.
  class CallbackBase < Proc
    extend TypeBase
    extend FFI::DataConverter

    def self.native_type
      FFI::Type::POINTER
    end

    def self.to_native(value, context)
      return nil unless value
      return value if FFI::Function === value
      FFI::Function.new gir_ffi_builder.return_type, gir_ffi_builder.argument_types, value
    end

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
        call_with_argument_mapping(prc, *args)
      end
    end
  end
end
