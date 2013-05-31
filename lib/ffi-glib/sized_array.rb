module GLib
  # Class representing an array with a determined size
  class SizedArray
    include Enumerable
    attr_reader :element_type, :size

    def initialize element_type, size, pointer
      @element_type = element_type
      @size = size
      @pointer = pointer
    end

    def to_ptr
      @pointer
    end

    def each &block
      # TODO: Move implementation from GirFFI::ArgHelper to here.
      # While doing so, the implentation could also become a real iterator
      arr = GirFFI::ArgHelper.ptr_to_typed_array(@element_type, @pointer, @size)
      if block_given?
        arr.each(&block)
      else
        arr.each
      end
    end

    def self.wrap element_type, size, pointer
      new element_type, size, pointer unless pointer.null?
    end
  end
end
