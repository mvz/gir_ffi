require 'ffi-glib/list_methods'

module GLib
  load_class :SList

  class SList
    include ListMethods
  end
end
