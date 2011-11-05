module GLib
  load_class :ByteArray

  # Overrides for GByteArray, GLib's automatically growing array of bytes.
  class ByteArray
    def to_string
      GirFFI::ArgHelper.ptr_to_utf8_length self[:data], self[:len]
    end
  end
end

