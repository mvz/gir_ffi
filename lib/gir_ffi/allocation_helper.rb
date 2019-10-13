# frozen_string_literal: true

require "gir_ffi/lib_c"

module GirFFI
  # Helper module for alloction-related functionality.
  module AllocationHelper
    def self.free_after(ptr)
      result = yield ptr
      LibC.free ptr unless ptr.null?
      result
    end
  end
end
