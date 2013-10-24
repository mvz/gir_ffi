require 'ffi-glib/list_methods'

module GLib
  load_class :List

  # Overrides for GList, GLib's doubly linked list implementation.
  class List
    include ListMethods

    def self.from_enumerable type, arr
      arr.inject(self.new type) { |lst, val|
        lst.append val }
    end

    def append data
      data_ptr = GirFFI::InPointer.from(element_type, data)
      self.class.wrap(element_type, Lib.g_list_append(self, data_ptr))
    end
  end
end
