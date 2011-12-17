module GLib
  # Represents a null-terminated array of strings.
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
      return if @ptr.null?
      offset = 0
      loop do
        ptr = @ptr.get_pointer offset
        break if ptr.null?
        yield ptr.read_string
        offset += POINTER_SIZE
      end
    end

    def self.wrap ptr
      self.new ptr
    end
  end
end
