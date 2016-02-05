# frozen_string_literal: true
module GLib
  # Common methods for GLib::Array and GLib::PtrArray
  module ArrayMethods
    # Re-implementation of the g_array_index and g_ptr_array_index macros
    def index(idx)
      if idx >= length || idx < 0
        raise IndexError, "Index #{idx} outside of bounds 0..#{length - 1}"
      end
      ptr = GirFFI::InOutPointer.new element_type, data_ptr + idx * element_size
      ptr.to_ruby_value
    end
  end
end
