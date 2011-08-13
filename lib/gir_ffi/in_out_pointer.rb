module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout.
  class InOutPointer < FFI::Pointer
    def self.for type, value
      ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
      size = FFI.type_size ffi_type
      ptr = AllocationHelper.safe_malloc(size)
      ptr.send "put_#{ffi_type}", 0, value
      self.new ptr
    end
  end
end

