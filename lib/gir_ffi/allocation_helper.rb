require 'gir_ffi/lib_c'

module GirFFI
  # Helper module providing a safe allocation method that raises an exception
  # if memory cannot be allocated.
  module AllocationHelper
    def self.safe_malloc(size)
      ptr = LibC.malloc size
      raise NoMemoryError if ptr.null?
      ptr
    end
  end
end
