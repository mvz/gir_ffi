require 'gir_ffi/ownable'

module GirFFI
  class Union < FFI::Union
    include Ownable
  end
end
