require 'gir_ffi/type_base'

module GirFFI
  module SignalBase
    include TypeBase

    # Create signal handler from a Proc. Makes sure arguments are properly
    # wrapped.
    def from prc
      wrap_in_callback_args_mapper(prc)
    end

    def wrap_in_callback_args_mapper prc
      return if !prc
      return prc if FFI::Function === prc
      return Proc.new do |*args|
        call_with_argument_mapping(prc, *args)
      end
    end
  end
end
