module GLib
  load_class :Array

  class Array
    attr_accessor :element_type

    def to_a
      GirFFI::ArgHelper.ptr_to_typed_array(self.element_type,
                                           self[:data], self[:len])
    end
  end
end


