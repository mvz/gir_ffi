module GLib
  load_class :Array

  # Overrides for GArray, GLib's automatically growing array. It should not
  # be necessary to create objects of this class from Ruby directly.
  class Array
    attr_accessor :element_type

    def self.new type
      ffi_type = type == :utf8 ? :pointer : type
      wrap(Lib.g_array_new(0, 0, FFI.type_size(ffi_type))).tap {|it|
        it.element_type = type}
    end

    def append_vals data
      bytes = GirFFI::InPointer.from_array element_type, data
      len = data.length
      Lib.g_array_append_vals(self, bytes, len)
      self
    end

    # FIXME: Make GirFII::InPointer support #each and use that.
    def each &block
      to_a.each &block
    end

    def to_a
      GirFFI::ArgHelper.ptr_to_typed_array(self.element_type,
                                           self[:data], self[:len])
    end
  end
end
