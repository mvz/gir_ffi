require 'ffi'

module GLib
  # Represents a null-terminated array of strings. GLib uses this
  # construction, but does not provide any actual functions for this class.
  class Strv
    include Enumerable

    POINTER_SIZE = FFI.type_size(:pointer)

    def initialize ptr
      @ptr = ptr
    end

    def to_ptr
      @ptr
    end

    def each
      reset_iterator or return
      while (ptr = next_ptr)
        yield ptr.read_string
      end
    end

    def self.wrap ptr
      self.new ptr
    end

    private

    def reset_iterator
      return if @ptr.null?
      @offset = 0
    end

    def next_ptr
      ptr = @ptr.get_pointer @offset
      @offset += POINTER_SIZE
      ptr unless ptr.null?
    end
  end
end
