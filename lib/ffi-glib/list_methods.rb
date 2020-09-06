# frozen_string_literal: true

require "ffi-glib/container_class_methods"

module GLib
  # Common methods for List and SList.
  module ListMethods
    include Enumerable
    attr_reader :element_type

    def self.included(base)
      # Override default field accessors.
      replace_method base, :next, :tail
      replace_method base, :data, :head

      base.extend ContainerClassMethods
      base.extend ClassMethods
    end

    def self.replace_method(base, old, new)
      base.class_eval do
        remove_method old
        alias_method old, new
      end
    end

    def initialize(type)
      store_pointer(FFI::Pointer.new(0))
      @element_type = type
    end

    def each
      reset_iterator
      while (elem = next_element)
        yield elem
      end
    end

    def tail
      return nil if struct.null?
      self.class.wrap(element_type, struct[:next])
    end

    def head
      return nil if struct.null?
      GirFFI::ArgHelper.cast_from_pointer(element_type, struct[:data])
    end

    def reset_typespec(typespec)
      @element_type = typespec
      self
    end

    def ==(other)
      to_a == other.to_a
    end

    private

    def reset_iterator
      @current = self
    end

    def next_element
      return unless @current

      element = @current.head
      @current = @current.tail
      element
    end

    def element_ptr_for(data)
      GirFFI::InPointer.from(element_type, data)
    end

    # Common class methods for List and SList
    module ClassMethods
      def from_enumerable(type, arr)
        arr.reduce(new(type)) { |lst, val| lst.prepend val }.reverse
      end
    end
  end
end
