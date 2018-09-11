# frozen_string_literal: true

require 'ffi'

module GObjectIntrospection
  # Represents a null-terminated array of strings.
  # GLib uses this
  # construction, but does not provide any actual functions for this class.
  class Strv
    include Enumerable

    POINTER_SIZE = FFI.type_size(:pointer)

    def initialize(ptr)
      @ptr = ptr
    end

    def to_ptr
      @ptr
    end

    def each
      offset = 0
      while (ptr = fetch_ptr offset)
        offset += POINTER_SIZE
        yield ptr.read_string
      end
    end

    def self.wrap(ptr)
      new ptr
    end

    private

    def fetch_ptr(offset)
      return if @ptr.null?

      ptr = @ptr.get_pointer offset
      ptr unless ptr.null?
    end
  end
end
