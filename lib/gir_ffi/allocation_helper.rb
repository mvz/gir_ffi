require 'gir_ffi/lib_c'

module GirFFI
  module AllocationHelper
    def self.safe_malloc size
      ptr = LibC.malloc size
      raise NoMemoryError if ptr.null?
      ptr
    end
  end
end
