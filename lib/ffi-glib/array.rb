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

    def append_vals ary
      bytes = GirFFI::InPointer.from_array element_type, ary
      len = ary.length
      Lib.g_array_append_vals(self, bytes, len)
      self
    end

    # Re-implementation of the g_array_index macro
    def index idx
      # TODO: Check idx < length
      ptr = GirFFI::InOutPointer.new element_type, data + idx * get_element_size
      bare_value = ptr.to_value
      case element_type
      when :utf8
        GirFFI::ArgHelper.ptr_to_utf8 bare_value
      when Symbol
        bare_value
      else
        element_type.wrap bare_value
      end
    end

    def each
      length.times.each do |idx|
        yield index(idx)
      end
    end

    def length
      @struct[:len]
    end

    def data
      @struct[:data]
    end

    def get_element_size
      Lib.g_array_get_element_size self
    end

    def ==(other)
      self.to_a == other.to_a
    end

    def self.wrap elmttype, ptr
      super(ptr).tap do |array|
        array.element_type = elmttype if array
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
      ffi_type = GirFFI::TypeMap.type_specification_to_ffitype(type)
      FFI.type_size(ffi_type)
    end

    def calculated_element_size
      self.class.calculated_element_size self.element_type
    end

    def check_element_size_match
      unless calculated_element_size == self.get_element_size
        warn "WARNING: Element sizes do not match"
      end
    end
  end
end
