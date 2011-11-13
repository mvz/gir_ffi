require 'ffi-glib/list_methods'

module GLib
  load_class :SList

  # Overrides for GSList, GLib's singly linked list implementation.
  class SList
    include ListMethods

    class << self
      undef :new
      def new type
        _real_new(FFI::Pointer.new(0)).tap {|it|
          it.element_type = type}
      end
    end

    def prepend data
      data_ptr = GirFFI::InPointer.from(element_type, data)
      self.class.wrap(element_type, Lib.g_slist_prepend(self, data_ptr))
    end

  end
end
