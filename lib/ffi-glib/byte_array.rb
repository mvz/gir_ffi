# frozen_string_literal: true
GLib.load_class :ByteArray

module GLib
  # Overrides for GByteArray, GLib's automatically growing array of bytes.
  class ByteArray
    def to_string
      data.read_string len
    end

    def append(data)
      bytes = GirFFI::InPointer.from_utf8 data
      len = data.bytesize
      self.class.wrap Lib.g_byte_array_append(to_ptr, bytes, len)
    end

    def initialize
      store_pointer(Lib.g_byte_array_new)
    end
  end
end
