module GLib
  load_class :ByteArray

  class ByteArray
    def to_string
      GirFFI::ArgHelper.ptr_to_utf8_length self[:data], self[:len]
    end
  end
end

