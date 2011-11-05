GirFFI.setup :GLib

require 'ffi-glib/s_list'
require 'ffi-glib/list'
require 'ffi-glib/hash_table'
require 'ffi-glib/byte_array'
require 'ffi-glib/array'
require 'ffi-glib/ptr_array'

module GLib
  # FIXME: Turn into real constructor
  def self.slist_new elmttype
    ::GLib::List._real_new(FFI::Pointer.new(0)).tap {|it|
      it.element_type = elmttype}
  end

  # FIXME: Turn into instance method; Use element type.
  def self.slist_prepend slist, data
    ::GLib::SList.wrap(slist.element_type, ::GLib::Lib.g_slist_prepend(slist, data))
  end

  # FIXME: Turn into real constructor
  def self.list_new elmttype
    ::GLib::List._real_new(FFI::Pointer.new(0)).tap {|it|
      it.element_type = elmttype}
  end

  # FIXME: Turn into instance method; Use element type.
  def self.list_append list, data
    ::GLib::List.wrap(list.element_type, ::GLib::Lib.g_list_append(list, data))
  end

  # FIXME: Turn into real constructor
  def self.hash_table_new keytype, valtype
    hash_fn, eq_fn = case keytype
                     when :utf8
                       lib = ::GLib::Lib.ffi_libraries.first
                       [ FFI::Function.new(:uint, [:pointer], lib.find_function("g_str_hash")),
                         FFI::Function.new(:int, [:pointer, :pointer], lib.find_function("g_str_equal"))]
                     else
                       [nil, nil]
                     end

    ::GLib::HashTable.wrap(keytype, valtype, ::GLib::Lib.g_hash_table_new(hash_fn, eq_fn))
  end

  # FIXME: Turn into real constructor
  def self.byte_array_new
    ::GLib::ByteArray.wrap(::GLib::Lib.g_byte_array_new)
  end

  # FIXME: Turn into instance method
  def self.byte_array_append arr, data
    bytes = GirFFI::InPointer.from :utf8, data
    len = data.bytesize
    ::GLib::ByteArray.wrap(::GLib::Lib.g_byte_array_append arr.to_ptr, bytes, len)
  end

  # FIXME: Turn into real constructor
  def self.array_new type
    ffi_type = type == :utf8 ? :pointer : type
    arr = ::GLib::Array.wrap(
      ::GLib::Lib.g_array_new(0, 0, FFI.type_size(ffi_type)))
    arr.element_type = type
    arr
  end

  # FIXME: Turn into instance method
  def self.array_append_vals arr, data
    bytes = GirFFI::InPointer.from_array arr.element_type, data
    len = data.length
    res = ::GLib::Array.wrap(
      ::GLib::Lib.g_array_append_vals(arr.to_ptr, bytes, len))
      res.element_type = arr.element_type
      res
  end

  # FIXME: Turn into real constructor?
  def self.main_loop_new context, is_running
    ::GLib::MainLoop.wrap(::GLib::Lib.g_main_loop_new context, is_running)
  end

  load_class :HFunc
  load_class :HashFunc
  load_class :EqualFunc
  module Lib
    attach_function :g_slist_prepend, [:pointer, :pointer], :pointer

    attach_function :g_list_append, [:pointer, :pointer], :pointer

    attach_function :g_hash_table_foreach,
      [:pointer, HFunc, :pointer], :void
    attach_function :g_hash_table_new,
      [HashFunc, EqualFunc], :pointer
    attach_function :g_hash_table_insert,
      [:pointer, :pointer, :pointer], :void

    attach_function :g_byte_array_new, [], :pointer
    attach_function :g_byte_array_append,
      [:pointer, :pointer, :uint], :pointer

    attach_function :g_array_new, [:int, :int, :uint], :pointer
    attach_function :g_array_append_vals,
      [:pointer, :pointer, :uint], :pointer

    attach_function :g_ptr_array_new, [], :pointer
    attach_function :g_ptr_array_add, [:pointer, :pointer], :void

    attach_function :g_main_loop_new, [:pointer, :bool], :pointer
  end
end
