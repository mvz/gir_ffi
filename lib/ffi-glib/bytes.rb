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

    # Why redefine new here? The class builder will only define the full
    # version of 'new' on first call, causing both new and initialize to be
    # defined. This overwrites the custom version of initialize below.
    # TODO: Improve class builder so this trick is not needed.
    class << self
      undef new
    end

    def self.new(*args)
      obj = allocate
      obj.__send__ :initialize, *args
      obj
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
