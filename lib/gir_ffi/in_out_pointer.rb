module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout.
  class InOutPointer < FFI::Pointer
  end
end

