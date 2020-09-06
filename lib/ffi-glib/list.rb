# frozen_string_literal: true

require "ffi-glib/list_methods"

GLib.load_class :List

module GLib
  # Overrides for GList, GLib's doubly linked list implementation.
  class List
    include ListMethods

    def self.from_enumerable(type, arr)
      arr.reduce(new(type)) { |lst, val| lst.prepend val }.reverse
    end

    def append(data)
      store_pointer Lib.g_list_append(self, element_ptr_for(data))
      self
    end

    def prepend(data)
      store_pointer Lib.g_list_prepend(self, element_ptr_for(data))
      self
    end

    def reverse
      store_pointer Lib.g_list_reverse(self)
      self
    end
  end
end
