# frozen_string_literal: true
require 'gir_ffi/lib_c'

module GirFFI
  # Helper module providing a safe allocation method that raises an exception
  # if memory cannot be allocated.
  module AllocationHelper
    def self.free_after(ptr)
      result = yield ptr
      LibC.free ptr unless ptr.null?
      result
    end
  end
end
