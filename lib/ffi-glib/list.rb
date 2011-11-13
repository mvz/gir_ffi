require 'ffi-glib/list_methods'

module GLib
  load_class :List

  # Overrides for GList, GLib's doubly linked list implementation.
  class List
    include ListMethods

    class << self
      undef :new
      def new type
        _real_new(FFI::Pointer.new(0)).tap {|it|
          it.element_type = type}
      end
    end

    def append data
      data_ptr = GirFFI::InPointer.from(element_type, data)
      self.class.wrap(element_type, Lib.g_list_append(self, data_ptr))
    end
  end
end
