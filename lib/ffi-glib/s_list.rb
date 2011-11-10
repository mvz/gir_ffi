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

    def prepend data
      data_ptr = case element_type
                 when :gint32
                   # FIXME: InPointer should handle that case also.
                   GirFFI::ArgHelper.cast_int32_to_pointer(data)
                 when :utf8
                   GirFFI::InPointer.from(:utf8, data)
                 else
                   raise NotImplementedError
                 end

      self.class.wrap(element_type, Lib.g_slist_prepend(self, data_ptr))
    end

  end
end
