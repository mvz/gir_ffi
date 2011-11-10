require 'ffi-glib/list_methods'

module GLib
  load_class :SList

  # Overrides for GSList, GLib's singly linked list implementation.
  class SList
    include ListMethods

    def self.new type
      _real_new(FFI::Pointer.new(0)).tap {|it|
        it.element_type = type}
    end
  end
end
