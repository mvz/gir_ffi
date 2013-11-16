# NOTE: Do not require this file directly. Require 'gir_ffi' instead.
#

GirFFI.setup :GLib

require 'ffi-glib/array'
require 'ffi-glib/byte_array'
require 'ffi-glib/hash_table'
require 'ffi-glib/list'
require 'ffi-glib/ptr_array'
require 'ffi-glib/s_list'
require 'ffi-glib/strv'
require 'ffi-glib/variant'

module GLib
  load_class :HFunc
  load_class :HashFunc
  load_class :EqualFunc
  load_class :Func

  module Lib
    attach_function :g_slist_prepend, [:pointer, :pointer], :pointer

    attach_function :g_list_append, [:pointer, :pointer], :pointer

    attach_function :g_hash_table_foreach, [:pointer, HFunc, :pointer], :void
    attach_function :g_hash_table_new, [HashFunc, EqualFunc], :pointer
    attach_function :g_hash_table_insert, [:pointer, :pointer, :pointer], :void

    attach_function :g_byte_array_new, [], :pointer
    attach_function :g_byte_array_append, [:pointer, :pointer, :uint], :pointer

    attach_function :g_array_new, [:int, :int, :uint], :pointer
    attach_function :g_array_append_vals, [:pointer, :pointer, :uint], :pointer
    attach_function :g_array_get_element_size, [:pointer], :uint

    attach_function :g_ptr_array_new, [], :pointer
    attach_function :g_ptr_array_add, [:pointer, :pointer], :void
    attach_function :g_ptr_array_foreach, [:pointer, Func, :pointer], :pointer
  end
end
