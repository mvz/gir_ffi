module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout.
  class InOutPointer < FFI::Pointer
    def self.from type, value
      ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type

      if type == :gboolean
        ffi_type = :int
        value = (value ? 1 : 0)
      end

      if type == :utf8
        sptr = InPointer.from :utf8, value
        size = FFI.type_size :pointer
        ptr = AllocationHelper.safe_malloc(size)
        ptr.write_pointer sptr
      else
        size = FFI.type_size ffi_type
        ptr = AllocationHelper.safe_malloc(size)
        ptr.send "put_#{ffi_type}", 0, value
      end

      self.new ptr
    end

    def self.from_array type, array
      return nil if array.nil?
      ptr = InPointer.from_array(type, array)
      self.from :pointer, ptr
    end
  end
end

