module GLib
  load_class :Array

  # Overrides for GArray, GLib's automatically growing array. It should not
  # be necessary to create objects of this class from Ruby directly.
  class Array
    include Enumerable

    attr_reader :element_type
    def element_type= val
      @element_type = val
      check_element_size_match
    end

    class << self
      undef :new
      def new type
        ptr = Lib.g_array_new(0, 0, calculated_element_size(type))
        wrap type, ptr
      end
    end

    def append_vals data
      bytes = GirFFI::InPointer.from_array element_type, data
      len = data.length
      Lib.g_array_append_vals(self, bytes, len)
      self
    end

    # Re-implementation of the g_array_index macro
    def index idx
      ptr = @struct[:data].get_pointer(idx * get_element_size)
      GirFFI::ArgHelper.cast_from_pointer(element_type, ptr)
    end

    def each
      @struct[:len].times.each do |idx|
        yield index(idx)
      end
    end

    def get_element_size
      GLib.array_get_element_size self
    end

    def self.wrap elmttype, ptr
      super(ptr).tap do |it|
        break if it.nil?
        it.element_type = elmttype
      end
    end

    def self.from elmtype, it
      case it
      when self then it
      when FFI::Pointer then wrap elmtype, it
      else self.new(elmtype).tap {|arr| arr.append_vals it }
      end
    end

    private

    def self.calculated_element_size type
      ffi_type = GirFFI::TypeMap.map_basic_type_or_string(type)
      FFI.type_size(ffi_type)
    end

    def calculated_element_size
      self.class.calculated_element_size self.element_type
    end

    def check_element_size_match
      unless calculated_element_size == self.get_element_size
        raise "Element sizes do not match"
      end
    end
  end
end
