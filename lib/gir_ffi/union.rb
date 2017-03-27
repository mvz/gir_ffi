# frozen_string_literal: true

require 'gir_ffi/ownable'

module GirFFI
  # Union that can be owned.
  class Union < FFI::Union
    include Ownable
  end
end
