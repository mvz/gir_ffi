require 'ffi-glib/list_methods'

module GLib
  load_class :SList

  # Overrides for GSList, GLib's singly-linked list implementation.
  class SList
    include ListMethods

    def self.from_enumerable type, arr
      arr.reverse.inject(self.new type) { |lst, val|
        lst.prepend val }
    end

    def prepend data
      data_ptr = GirFFI::InPointer.from(element_type, data)
      self.class.wrap(element_type, Lib.g_slist_prepend(self, data_ptr))
    end
  end
end
