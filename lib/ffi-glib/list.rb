# frozen_string_literal: true
require 'ffi-glib/list_methods'

GLib.load_class :List

module GLib
  # Overrides for GList, GLib's doubly linked list implementation.
  class List
    include ListMethods

    def self.from_enumerable(type, arr)
      arr.reduce(new(type)) { |lst, val| lst.append val }
    end

    def append(data)
      self.class.wrap(element_type,
                      Lib.g_list_append(self, element_ptr_for(data)))
    end
  end
end
