# frozen_string_literal: true
require 'ffi'
require 'gir_ffi-base/glib'

module GLib
  # Represents a null-terminated array of strings. GLib uses this
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
      return if @ptr.null?
      reset_iterator
      while (ptr = next_ptr)
        yield ptr.read_string
      end
    end

    def self.wrap(ptr)
      new ptr
    end

    private

    def reset_iterator
      @offset = 0
    end

    def next_ptr
      ptr = @ptr.get_pointer @offset
      @offset += POINTER_SIZE
      ptr unless ptr.null?
    end
  end
end
