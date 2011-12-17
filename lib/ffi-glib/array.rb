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
        ptr = Lib.g_array_new(0, 0, element_type_size(type))
        wrap type, ptr
      end
    end

    def append_vals data
      bytes = GirFFI::InPointer.from_array element_type, data
      len = data.length
      Lib.g_array_append_vals(self, bytes, len)
      self
    end

    def each &block
      Enumerator.new do |yielder|
        @struct[:len].times.each do |idx|
          ptr = @struct[:data].get_pointer(idx * element_type_size)
          val = GirFFI::ArgHelper.cast_from_pointer(element_type, ptr)
          yielder << val
        end
      end.each &block
    end

    def self.wrap elmttype, ptr
      super(ptr).tap do |it|
        break if it.nil?
        it.element_type = elmttype
      end
    end

    def self.from elmtype, it
      case it
      when self then it # TODO: Set element type also?
      when FFI::Pointer then wrap elmtype, it
      else self.new(elmtype).tap {|arr| arr.append_vals it }
      end
    end

    def self.element_type_size type
      ffi_type = GirFFI::TypeMap.map_basic_type_or_string(type)
      FFI.type_size(ffi_type)
    end

    def element_type_size
      self.class.element_type_size self.element_type
    end
  end
end
