module GLib
  load_class :PtrArray

  class PtrArray
    attr_accessor :element_type
    def self.new type
      wrap(::GLib::Lib.g_ptr_array_new).tap {|it|
        it.element_type = type}
    end

    def self.add array, data
      ptr = cast_to_pointer array.element_type, data
      ::GLib::Lib.g_ptr_array_add array, ptr
    end

    def self.cast_to_pointer type, it
      if type == :utf8
        GirFFI::InPointer.from :utf8, it
      else
        raise NotImplementedError
      end
    end

  end
end
