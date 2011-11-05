require 'ffi-glib/list_methods'

module GLib
  load_class :SList

  # Overrides for GSList, GLib's singly linked list implementation.
  class SList
    include ListMethods
  end
end
