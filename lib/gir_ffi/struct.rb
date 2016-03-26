require 'gir_ffi/ownable'

module GirFFI
  class Struct < FFI::Struct
    include Ownable
  end
end
