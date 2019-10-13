# frozen_string_literal: true

require "gir_ffi/ownable"

module GirFFI
  # Struct that can be owned.
  class Struct < FFI::Struct
    include Ownable
  end
end
