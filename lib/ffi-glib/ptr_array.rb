require 'ffi-glib/container_class_methods'
require 'ffi-glib/array_methods'

module GLib
  load_class :PtrArray

  # Overrides for GPtrArray, GLib's automatically growing array of
  # pointers.
  class PtrArray
    include Enumerable
    include ArrayMethods
    extend ContainerClassMethods

    attr_reader :element_type

    POINTER_SIZE = FFI.type_size(:pointer)

    class << self
      remove_method :new
      # Remove stub generated by builder.
      remove_method :add if method_defined? :add
    end

    def self.new type
      wrap(type, Lib.g_ptr_array_new)
    end

    def self.from_enumerable type, it
      self.new(type).tap {|arr| arr.add_array it}
    end

    def self.add array, data
      array.add data
    end

    def reset_typespec typespec
      @element_type = typespec
      self
    end

    def add data
      ptr = GirFFI::InPointer.from element_type, data
      Lib.g_ptr_array_add self, ptr
    end

    def add_array ary
      ary.each {|item| add item}
    end

    def data_ptr
      @struct[:pdata]
    end

    def element_size
      POINTER_SIZE
    end

    def each
      length.times do |idx|
        yield index(idx)
      end
    end

    def length
      @struct[:len]
    end

    def == other
      self.to_a == other.to_a
    end
  end
end
