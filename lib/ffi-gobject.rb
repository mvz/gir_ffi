GirFFI.setup :GObject

require 'ffi-gobject/value'
require 'ffi-gobject/initially_unowned'
require 'ffi-gobject/closure'
require 'ffi-gobject/object'
require 'ffi-gobject/ruby_closure'
require 'ffi-gobject/helper'

module GObject
  def self.type_init
    Lib::g_type_init
  end

  def self.object_ref obj
    Lib::g_object_ref obj.to_ptr
  end

  def self.object_ref_sink obj
    Lib::g_object_ref_sink obj.to_ptr
  end

  def self.object_unref obj
    Lib::g_object_unref obj.to_ptr
  end

  def self.object_is_floating obj
    Lib::g_object_is_floating obj.to_ptr
  end

  def self.type_from_instance_pointer inst_ptr
    return nil if inst_ptr.null?
    klsptr = inst_ptr.get_pointer 0
    klsptr.send "get_#{GirFFI::TypeMap::TAG_TYPE_MAP[:gtype]}", 0
  end

  def self.type_from_instance instance
    type_from_instance_pointer instance.to_ptr
  end

  _setup_method :signal_emitv

  def self.signal_lookup_from_instance signal, object
    signal_lookup signal, type_from_instance(object)
  end

  def self.signal_emit object, signal, *args
    id = signal_lookup_from_instance signal, object
    arr = Helper.signal_arguments_to_gvalue_array signal, object, *args
    rval = Helper.gvalue_for_signal_return_value signal, object

    Lib.g_signal_emitv arr[:values], id, 0, rval

    return rval
  end

  def self.signal_connect object, signal, data=nil, &block
    callback = Helper.signal_callback object.class, signal, &block
    data_ptr = GirFFI::ArgHelper.object_to_inptr data

    Lib::CALLBACKS << callback

    Lib.g_signal_connect_data object, signal, callback, data_ptr, nil, 0
  end

  load_class :Callback
  load_class :ClosureNotify
  load_class :ConnectFlags
  load_class :ClosureMarshal

  module Lib
    attach_function :g_type_init, [], :void
    attach_function :g_object_ref, [:pointer], :void
    attach_function :g_object_ref_sink, [:pointer], :void
    attach_function :g_object_unref, [:pointer], :void
    attach_function :g_object_is_floating, [:pointer], :bool

    attach_function :g_signal_connect_data,
      [:pointer, :string, Callback, :pointer, ClosureNotify,
        ConnectFlags],
        :ulong
    attach_function :g_closure_set_marshal,
      [:pointer, ClosureMarshal], :void
  end

  TYPE_INVALID = type_from_name("invalid")
  TYPE_NONE = type_from_name("void")
  TYPE_INTERFACE = type_from_name("GInterface")
  TYPE_CHAR = type_from_name("gchar")
  TYPE_UCHAR = type_from_name("guchar")
  TYPE_BOOLEAN = type_from_name("gboolean")
  TYPE_INT = type_from_name("gint")
  TYPE_UINT = type_from_name("guint")
  TYPE_LONG = type_from_name("glong")
  TYPE_ULONG = type_from_name("gulong")
  TYPE_INT64 = type_from_name("gint64")
  TYPE_UINT64 = type_from_name("guint64")
  TYPE_ENUM = type_from_name("GEnum")
  TYPE_FLAGS = type_from_name("GFlags")
  TYPE_FLOAT = type_from_name("gfloat")
  TYPE_DOUBLE = type_from_name("gdouble")
  TYPE_STRING = type_from_name("gchararray")
  TYPE_POINTER = type_from_name("gpointer")
  TYPE_BOXED = type_from_name("GBoxed")
  TYPE_PARAM = type_from_name("GParam")
  TYPE_OBJECT = type_from_name("GObject")
  TYPE_GTYPE = type_from_name("GType")
  TYPE_VARIANT = type_from_name("GVariant")
  TYPE_HASH_TABLE = type_from_name("GHashTable")

  TYPE_TAG_TO_GTYPE = {
    :void => TYPE_NONE,
    :gboolean => TYPE_BOOLEAN,
    :gint32 => TYPE_INT,
    :gfloat => TYPE_FLOAT,
    :gdouble => TYPE_DOUBLE,
    :utf8 => TYPE_STRING,
    :ghash => TYPE_HASH_TABLE,
    :glist => TYPE_POINTER
  }
end
