module GLib
  module ListClassMethods
    def wrap elmttype, ptr
      super(ptr).tap do |it|
        break if it.nil?
        it.element_type = elmttype
      end
    end
  end
end
