require 'ffi-glib/list_methods'

module GLib
  load_class :List

  # Overrides for GList, GLib's doubly linked list implementation.
  class List
    include ListMethods

    def self.new type
      _real_new(FFI::Pointer.new(0)).tap {|it|
        it.element_type = type}
    end
  end
end
