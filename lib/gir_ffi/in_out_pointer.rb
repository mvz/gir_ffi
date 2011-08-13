module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout.
  class InOutPointer < FFI::Pointer
    def self.from type, value
      return from_gboolean value if type == :gboolean
      return from_utf8 value if type == :utf8

      ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type

      size = FFI.type_size ffi_type
      ptr = AllocationHelper.safe_malloc(size)
      ptr.send "put_#{ffi_type}", 0, value

      self.new ptr
    end

    def self.from_array type, array
      return nil if array.nil?
      ptr = InPointer.from_array(type, array)
      self.from :pointer, ptr
    end

    class << self
      private

      def from_gboolean value
        self.from :gint32, (value ? 1 : 0)
      end

      def from_utf8 value
        ptr = InPointer.from :utf8, value
        self.from :pointer, ptr
      end
    end
  end
end

