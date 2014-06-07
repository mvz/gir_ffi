require 'ffi-glib/container_class_methods'
require 'ffi-glib/array_methods'

GLib.load_class :Array

module GLib
  # Overrides for GArray, GLib's automatically growing array. It should not
  # be necessary to create objects of this class from Ruby directly.
  class Array
    include Enumerable
    include ArrayMethods
    extend ContainerClassMethods

    attr_reader :element_type

    class << self; undef :new; end

    def self.new type
      ptr = Lib.g_array_new(0, 0, calculated_element_size(type))
      wrap type, ptr
    end

    def append_vals ary
      bytes = GirFFI::InPointer.from_array element_type, ary
      Lib.g_array_append_vals(self, bytes, ary.length)
      self
    end

    def each
      length.times do |idx|
        yield index(idx)
      end
    end

    def length
      @struct[:len]
    end

    def data_ptr
      @struct[:data]
    end

    def get_element_size
      Lib.g_array_get_element_size self
    end

    alias element_size get_element_size

    def == other
      to_a == other.to_a
    end

    def reset_typespec typespec
      @element_type = typespec
      check_element_size_match
      self
    end

    def self.from_enumerable elmtype, it
      new(elmtype).tap {|arr| arr.append_vals it }
    end

    private

    def self.calculated_element_size type
      ffi_type = GirFFI::TypeMap.type_specification_to_ffitype(type)
      FFI.type_size(ffi_type)
    end

    def calculated_element_size
      self.class.calculated_element_size element_type
    end

    def check_element_size_match
      unless calculated_element_size == get_element_size
        warn "WARNING: Element sizes do not match"
      end
    end
  end
end
