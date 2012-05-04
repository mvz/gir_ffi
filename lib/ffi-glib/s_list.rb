require 'ffi-glib/list_methods'

module GLib
  load_class :SList

  # Overrides for GSList, GLib's singly-linked list implementation.
  class SList
    include ListMethods

    class << self
      remove_method :new
    end

    def self.new type
      _real_new.tap do |it|
        struct = ffi_structure.new(FFI::Pointer.new(0))
        it.instance_variable_set :@struct, struct
        it.element_type = type
      end
    end

    def self.from_enumerable type, arr
      arr.reverse.inject(self.new type) { |lst, val|
        lst.prepend val }
    end

    def prepend data
      elm_t = element_type
      data_ptr = GirFFI::InPointer.from(elm_t, data)
      self.class.wrap(elm_t, Lib.g_slist_prepend(self, data_ptr))
    end
  end
end
