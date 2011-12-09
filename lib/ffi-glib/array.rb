module GLib
  load_class :Array

  # Overrides for GArray, GLib's automatically growing array. It should not
  # be necessary to create objects of this class from Ruby directly.
  class Array
    include Enumerable

    attr_accessor :element_type

    class << self
      undef :new
      def new type
        ffi_type = GirFFI::TypeMap.map_basic_type_or_string(type)
        ptr = Lib.g_array_new(0, 0, FFI.type_size(ffi_type))
        wrap type, ptr
      end
    end

    def append_vals data
      bytes = GirFFI::InPointer.from_array element_type, data
      len = data.length
      Lib.g_array_append_vals(self, bytes, len)
      self
    end

    # FIXME: Make GirFII::InPointer support #each and use that.
    def each &block
      to_typed_array.each(&block)
    end

    def self.wrap elmttype, ptr
      super(ptr).tap do |it|
        break if it.nil?
        it.element_type = elmttype
      end
    end

    private

    def to_typed_array
      GirFFI::ArgHelper.ptr_to_typed_array(self.element_type,
                                           @struct[:data], @struct[:len])
    end
  end
end
