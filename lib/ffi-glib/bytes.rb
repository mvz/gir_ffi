# frozen_string_literal: true

GLib.load_class :Bytes

module GLib
  # Overrides for GBytes, GLib's immutable array of bytes.
  class Bytes
    include Enumerable

    remove_method :get_data if method_defined? :get_data

    # @override
    # NOTE: Needed due to mis-identification of the element-type of the
    # resulting sized array for the default binding.
    def get_data
      length_ptr = FFI::MemoryPointer.new :size_t
      data_ptr = Lib.g_bytes_get_data self, length_ptr
      length = length_ptr.get_size_t(0)
      GirFFI::SizedArray.wrap(:guint8, length, data_ptr)
    end

    def each(&block)
      data.each(&block)
    end

    def self.from(it)
      case it
      when self
        it
      when FFI::Pointer
        wrap it
      else
        new it
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
