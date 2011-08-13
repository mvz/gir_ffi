module GirFFI
  # The OutPointer class handles setup of pointers and their conversion to
  # ruby types for arguments with direction :out.
  class OutPointer < FFI::Pointer
  end
end
