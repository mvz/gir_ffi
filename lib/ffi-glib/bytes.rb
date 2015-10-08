GLib.load_class :Bytes

module GLib
  # Overrides for GBytes, GLib's immutable array of bytes.
  class Bytes
    include Enumerable

    remove_method :get_data if method_defined? :get_data

    # @override
    def get_data
      length_ptr = GirFFI::InOutPointer.for :gsize
      data_ptr = Lib.g_bytes_get_data self, length_ptr
      length = length_ptr.to_value
      # NOTE: Needed due to mis-identification of the element-type of the
      # resulting sized array for the default binding.
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

    private

    def data
      @data ||= get_data
    end
  end
end
