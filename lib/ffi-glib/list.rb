require 'ffi-glib/list_methods'

module GLib
  load_class :List

  # Overrides for GList, GLib's doubly linked list implementation.
  class List
    include ListMethods

    # Override default field accessors.
    undef :next
    undef :data

    alias :next :tail
    alias :data :head

    class << self
      undef :new
      def new type
        _real_new.tap do |it|
          struct = ffi_structure.new(FFI::Pointer.new(0))
          it.instance_variable_set :@struct, struct
          it.element_type = type
        end
      end

      def from_array type, arr
        return nil if arr.nil?
        if arr.is_a? self
          arr.element_type = type
          return arr
        end
        arr.inject(self.new type) { |lst, val|
          lst.append val }
      end
    end

    def append data
      data_ptr = GirFFI::InPointer.from(element_type, data)
      self.class.wrap(element_type, Lib.g_list_append(self, data_ptr))
    end
  end
end
