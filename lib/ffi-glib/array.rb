# frozen_string_literal: true

require "ffi-glib/container_class_methods"
require "gir_ffi/array_element_convertor"

GLib.load_class :Array

module GLib
  # Overrides for GArray, GLib's automatically growing array. It should not
  # be necessary to create objects of this class from Ruby directly.
  class Array
    include Enumerable
    extend ContainerClassMethods

    attr_reader :element_type

    def initialize(type)
      @element_type = type
      ptr = Lib.g_array_new(0, 0, calculated_element_size)
      store_pointer(ptr)
    end

    # @api private
    def self.from_enumerable(elmtype, arr)
      new(elmtype).tap { |it| it.append_vals arr }
    end

    # @api private
    def self.calculated_element_size(type)
      ffi_type = GirFFI::TypeMap.type_specification_to_ffi_type(type)
      FFI.type_size(ffi_type)
    end

    # @override
    def append_vals(ary)
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
      struct[:len]
    end

    def get_element_size
      Lib.g_array_get_element_size self
    end

    alias element_size get_element_size

    def ==(other)
      to_a == other.to_a
    end

    # @api private
    def reset_typespec(typespec = nil)
      if typespec
        @element_type = typespec
        check_element_size_match
      else
        @element_type = guess_element_type
      end
      self
    end

    # Re-implementation of the g_array_index macro
    def index(idx)
      unless (0...length).cover? idx
        raise IndexError, "Index #{idx} outside of bounds 0..#{length - 1}"
      end

      item_ptr = data_ptr + idx * element_size
      convertor = GirFFI::ArrayElementConvertor.new element_type, item_ptr
      convertor.to_ruby_value
    end

    private

    def data_ptr
      struct[:data]
    end

    def calculated_element_size
      self.class.calculated_element_size element_type
    end

    def check_element_size_match
      return if calculated_element_size == get_element_size

      warn "WARNING: Element sizes do not match"
    end

    def guess_element_type
      case get_element_size
      when 1 then :uint8
      when 2 then :uint16
      when 4 then :uint32
      when 8 then :uint64
      end
    end
  end
end
