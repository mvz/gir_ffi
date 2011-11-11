module GLib
  load_class :ByteArray

  # Overrides for GByteArray, GLib's automatically growing array of bytes.
  class ByteArray
    def to_string
      GirFFI::ArgHelper.ptr_to_utf8_length self[:data], self[:len]
    end

    def append data
      bytes = GirFFI::InPointer.from :utf8, data
      len = data.bytesize
      self.class.wrap(Lib.g_byte_array_append self.to_ptr, bytes, len)
    end

    def self.new
      wrap(Lib.g_byte_array_new)
    end
  end
end

