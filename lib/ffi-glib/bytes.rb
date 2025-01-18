# frozen_string_literal: true

GLib.load_class :Bytes

module GLib
  # Overrides for GBytes, GLib's immutable array of bytes.
  class Bytes
    include Enumerable

    def each(&)
      data.each(&)
    end

    def self.from(obj)
      case obj
      when self
        obj
      when FFI::Pointer
        wrap obj
      else
        new obj
      end
    end

    def initialize(arr)
      data = GirFFI::SizedArray.from :guint8, arr.size, arr
      store_pointer Lib.g_bytes_new data.to_ptr, data.size
    end

    private

    def data
      @data ||= get_data
    end
  end
end
