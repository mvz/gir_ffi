# NOTE: Do not require this file directly. Require 'gir_ffi' instead.
#

GirFFI.setup :GObject

require 'ffi-gobject/base'

require 'ffi-gobject/value'
require 'ffi-gobject/initially_unowned'
require 'ffi-gobject/closure'
require 'ffi-gobject/object'
require 'ffi-gobject/ruby_closure'
require 'gir_ffi/builders/user_defined_builder'

module GObject
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
    klsptr.send "get_#{GirFFI::TypeMap::TAG_TYPE_MAP[:GType]}", 0
  end

  def self.type_from_instance instance
    type_from_instance_pointer instance.to_ptr
  end

  def self.object_class_from_instance instance
    object_class_from_instance_pointer instance.to_ptr
  end

  def self.object_class_from_instance_pointer inst_ptr
    return nil if inst_ptr.null?
    klsptr = inst_ptr.get_pointer 0
    ObjectClass.wrap klsptr
  end

  setup_method :signal_emitv

  def self.signal_lookup_from_instance signal, object
    signal_lookup signal, type_from_instance(object)
  end

  def self.signal_emit object, detailed_signal, *args
    signal, detail = detailed_signal.split('::')
    signal_id = signal_lookup_from_instance signal, object
    detail_quark = GLib.quark_from_string(detail)
    sig_info = object.class.find_signal signal
    arr = sig_info.signal_arguments_to_gvalue_array object, *args
    rval = sig_info.gvalue_for_signal_return_value

    Lib.g_signal_emitv arr.values, signal_id, detail_quark, rval

    return rval
  end

  def self.signal_connect object, detailed_signal, data=nil, &block
    signal, _ = detailed_signal.split('::')
    sig_info = object.class.find_signal signal
    callback = sig_info.signal_callback(&block)
    GirFFI::CallbackBase.store_callback callback

    data_ptr = GirFFI::InPointer.from_object data

    Lib.g_signal_connect_data object, detailed_signal, callback, data_ptr, nil, 0
  end

  # Smells of :reek:LongParameterList: due to the C interface.
  def self.param_spec_int(name, nick, blurb, minimum, maximum,
                          default_value, flags)
    ptr = Lib.g_param_spec_int(name, nick, blurb, minimum, maximum,
                               default_value, flags)
    ParamSpecInt.wrap(ptr)
  end

  load_class :Callback
  load_class :ClosureNotify
  load_class :ConnectFlags
  load_class :ClosureMarshal
  load_class :ParamFlags

  module Lib
    # NOTE: This Lib module is set up in `gir_ffi-base/gobject/lib.rb`.

    attach_function :g_object_ref, [:pointer], :void
    attach_function :g_object_ref_sink, [:pointer], :void
    attach_function :g_object_unref, [:pointer], :void
    attach_function :g_object_is_floating, [:pointer], :bool

    attach_function :g_array_get_type, [], :size_t
    attach_function :g_hash_table_get_type, [], :size_t
    attach_function :g_strv_get_type, [], :size_t

    attach_function :g_signal_connect_data,
      [:pointer, :string, Callback::Callback, :pointer, ClosureNotify::Callback, ConnectFlags],
      :ulong
    attach_function :g_closure_set_marshal,
      [:pointer, ClosureMarshal::Callback], :void

    attach_function :g_param_spec_int,
      [:string, :string, :string, :int32, :int32, :int32, ParamFlags],
      :pointer
  end

  TYPE_ARRAY = Lib.g_array_get_type
  TYPE_HASH_TABLE = Lib.g_hash_table_get_type
  TYPE_STRV = Lib.g_strv_get_type

  TYPE_TAG_TO_GTYPE = {
    :array => TYPE_ARRAY,
    :gboolean => TYPE_BOOLEAN,
    :gdouble => TYPE_DOUBLE,
    :gfloat => TYPE_FLOAT,
    :ghash => TYPE_HASH_TABLE,
    :gint32 => TYPE_INT,
    :glist => TYPE_POINTER,
    :utf8 => TYPE_STRING,
    :void => TYPE_NONE
  }
end
