require 'ffi-glib/list_methods'

module GLib
  load_class :List

  # Overrides for GList, GLib's doubly linked list implementation.
  class List
    include ListMethods

    class << self
      undef :new
    end

    def self.new type
      _real_new.tap do |it|
        struct = ffi_structure.new(FFI::Pointer.new(0))
        it.instance_variable_set :@struct, struct
        it.element_type = type
      end
    end

    def self.from_enumerable type, arr
      arr.inject(self.new type) { |lst, val|
        lst.append val }
    end

    def append data
      elm_t = element_type
      data_ptr = GirFFI::InPointer.from(elm_t, data)
      self.class.wrap(elm_t, Lib.g_list_append(self, data_ptr))
    end
  end
end
