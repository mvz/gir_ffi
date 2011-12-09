module GLib
  module ListMethods
    include Enumerable
    attr_accessor :element_type

    def self.included base
      base.extend ClassMethods
    end

    def each
      list = self
      rval = nil
      until list.nil?
        rval = yield list.head
        list = list.tail
      end
      rval
    end

    def tail
      self.class.wrap(element_type, @struct[:next])
    end

    def head
      GirFFI::ArgHelper.cast_from_pointer(element_type, @struct[:data])
    end

    module ClassMethods
      def wrap elmttype, ptr
        return nil if ptr.nil?
        if ptr.is_a? FFI::Pointer
          super(ptr).tap do |it|
            break if it.nil?
            it.element_type = elmttype
          end
        else
          self.from_array elmttype, ptr
        end
      end
    end
  end
end


