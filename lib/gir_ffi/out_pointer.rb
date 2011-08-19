module GirFFI
  # The OutPointer class handles setup of pointers and their conversion to
  # ruby types for arguments with direction :out.
  class OutPointer < FFI::Pointer
    def self.for type
      ffi_type = InOutPointer.type_to_ffi_type type
      ptr = AllocationHelper.safe_malloc(FFI.type_size ffi_type)
      ptr.send "put_#{ffi_type}", 0, 0
      self.new ptr
    end
  end
end
