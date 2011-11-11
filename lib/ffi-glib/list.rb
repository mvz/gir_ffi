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

    def append data
      data_ptr = case element_type
                 when :gint32
                   # FIXME: InPointer should handle that case also.
                   GirFFI::ArgHelper.cast_int32_to_pointer(data)
                 when :utf8
                   GirFFI::InPointer.from(:utf8, data)
                 else
                   raise NotImplementedError
                 end

      self.class.wrap(element_type, Lib.g_list_append(self, data_ptr))
    end
  end
end
