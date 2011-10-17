require 'ffi-glib/list_methods'

module GLib
  load_class :List

  class List
    include ListMethods
  end
end
