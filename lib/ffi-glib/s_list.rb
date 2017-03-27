# frozen_string_literal: true

require 'ffi-glib/list_methods'

GLib.load_class :SList

module GLib
  # Overrides for GSList, GLib's singly-linked list implementation.
  class SList
    include ListMethods

    def self.from_enumerable(type, arr)
      arr.reverse.reduce(new(type)) { |lst, val| lst.prepend val }
    end

    def prepend(data)
      self.class.wrap(element_type,
                      Lib.g_slist_prepend(self, element_ptr_for(data)))
    end
  end
end
