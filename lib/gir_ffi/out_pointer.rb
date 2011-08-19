require 'gir_ffi/in_out_pointer'

module GirFFI
  # The OutPointer class handles setup of pointers and their conversion to
  # ruby types for arguments with direction :out.
  class OutPointer < InOutPointer
  end
end
