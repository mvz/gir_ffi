require 'ffi-glib/list_methods'

module GLib
  load_class :List

  # Overrides for GList, GLib's doubly linked list implementation.
  class List
    include ListMethods
  end
end
