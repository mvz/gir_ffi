module GirFFI
  # The OutPointer class handles setup of pointers and their conversion to
  # ruby types for arguments with direction :out.
  class OutPointer < FFI::Pointer
    def self.for type
      ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type

      ffi_type = :int if type == :gboolean
      ffi_type = :pointer if type == :utf8

      size = FFI.type_size ffi_type
      ptr = AllocationHelper.safe_malloc(size)
      ptr.send "put_#{ffi_type}", 0, 0
      self.new ptr
    end
  end
end
