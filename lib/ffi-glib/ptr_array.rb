module GLib
  load_class :PtrArray

  class PtrArray
    attr_accessor :element_type
    def self.new type
      wrap(::GLib::Lib.g_ptr_array_new).tap {|it|
        it.element_type = type}
    end
  end
end
