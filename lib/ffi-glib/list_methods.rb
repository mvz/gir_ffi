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
        rval = yield list.data
        list = list.next
      end
      rval
    end

    def next
      self.class.wrap(element_type, self[:next])
    end

    def data
      GirFFI::ArgHelper.cast_from_pointer(element_type, self[:data])
    end

    module ClassMethods
      def wrap elmttype, ptr
        super(ptr).tap do |it|
          break if it.nil?
          it.element_type = elmttype
        end
      end
    end
  end
end


