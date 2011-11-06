GirFFI.setup :GObject

require 'ffi-gobject/value'
require 'ffi-gobject/initially_unowned'
require 'ffi-gobject/closure'
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
    klsptr = inst_ptr.get_pointer 0
    klsptr.send "get_#{GirFFI::TypeMap::TAG_TYPE_MAP[:gtype]}", 0
  end

  def self.type_from_instance instance
    type_from_instance_pointer instance.to_ptr
  end

  _setup_method :signal_emitv

  def self.signal_emit object, signal, *args
    type = type_from_instance object
    id = signal_lookup signal, type

    arr = Helper.signal_arguments_to_gvalue_array signal, object, *args
    rval = Helper.gvalue_for_signal_return_value signal, object

    ::GObject::Lib.g_signal_emitv arr[:values], id, 0, rval

    rval
  end

  def self.signal_connect object, signal, data=nil, &block
    callback = Helper.signal_callback object.class, signal, &block
    data_ptr = GirFFI::ArgHelper.object_to_inptr data
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
end
