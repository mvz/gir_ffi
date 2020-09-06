# frozen_string_literal: true

# Ensure GLib is defined by GirFFI itself
raise "The module GLib was already defined elsewhere" if Kernel.const_defined? :GLib

require "gir_ffi/core"

# Set up the GLib module, bypassing the check for existing modules. This also
# creates GLib::Lib.
GirFFI::Builders::ModuleBuilder.new("GLib").generate

require "ffi-glib/array"
require "ffi-glib/byte_array"
require "ffi-glib/bytes"
require "ffi-glib/destroy_notify"
require "ffi-glib/error"
require "ffi-glib/hash_table"
require "ffi-glib/list"
require "ffi-glib/main_loop"
require "ffi-glib/ptr_array"
require "ffi-glib/s_list"
require "ffi-glib/strv"
require "ffi-glib/variant"

# Module representing GLib's GLib namespace.
module GLib
  load_class :HFunc
  load_class :HashFunc
  load_class :EqualFunc
  load_class :Func

  # Module for attaching functions from the glib library. This module is
  # defined by the call to ModuleBuilder#generate above.
  module Lib
    attach_function :g_slist_prepend, [:pointer, :pointer], :pointer

    attach_function :g_list_append, [:pointer, :pointer], :pointer
    attach_function :g_list_prepend, [:pointer, :pointer], :pointer

    attach_function :g_hash_table_foreach, [:pointer, HFunc, :pointer], :void
    attach_function :g_hash_table_new, [HashFunc, EqualFunc], :pointer
    attach_function :g_hash_table_insert, [:pointer, :pointer, :pointer], :void

    attach_function :g_byte_array_new, [], :pointer
    attach_function :g_byte_array_append, [:pointer, :pointer, :uint], :pointer

    attach_function :g_bytes_get_data, [:pointer, :pointer], :pointer
    attach_function :g_bytes_new, [:pointer, :size_t], :pointer

    attach_function :g_array_new, [:int, :int, :uint], :pointer
    attach_function :g_array_append_vals, [:pointer, :pointer, :uint], :pointer
    attach_function :g_array_get_element_size, [:pointer], :uint

    attach_function :g_ptr_array_new, [], :pointer
    attach_function :g_ptr_array_add, [:pointer, :pointer], :void
    attach_function :g_ptr_array_foreach, [:pointer, Func, :pointer], :pointer

    attach_function :g_iconv_open, [:pointer, :pointer], :pointer
    attach_function :g_variant_ref_sink, [:pointer], :pointer
  end
end
