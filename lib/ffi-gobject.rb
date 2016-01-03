require 'gir_ffi/core'

GirFFI.setup :GObject

require 'ffi-gobject/base'

require 'ffi-gobject/value'
require 'ffi-gobject/initially_unowned'
require 'ffi-gobject/closure'
require 'ffi-gobject/object'
require 'ffi-gobject/object_class'
require 'ffi-gobject/ruby_closure'
require 'gir_ffi/builders/user_defined_builder'

# Module representing GLib's GObject namespace.
module GObject
  def self.type_from_instance_pointer(inst_ptr)
    return nil if inst_ptr.null?
    klsptr = inst_ptr.get_pointer 0
    GirFFI::InOutPointer.new(:GType, klsptr).to_value
  end

  def self.type_from_instance(instance)
    type_from_instance_pointer instance.to_ptr
  end

  def self.object_class_from_instance(instance)
    object_class_from_instance_pointer instance.to_ptr
  end

  def self.object_class_from_instance_pointer(inst_ptr)
    return nil if inst_ptr.null?
    klsptr = inst_ptr.get_pointer 0
    ObjectClass.wrap klsptr
  end

  def self.signal_lookup_from_instance(signal, object)
    signal_lookup signal, type_from_instance(object)
  end

  def self.signal_emit(object, detailed_signal, *args)
    signal, detail = detailed_signal.split('::')
    signal_id = signal_lookup_from_instance signal, object
    detail_quark = GLib.quark_from_string(detail)

    sig_info = object.class.find_signal signal
    argument_gvalues = sig_info.arguments_to_gvalues object, args
    return_gvalue = sig_info.gvalue_for_return_value

    result = signal_emitv argument_gvalues, signal_id, detail_quark, return_gvalue
    # NOTE: Depending on the version of GObjectIntrospection, the result will
    # be stored in result or return_gvalue. This was changed between versions
    # 1.44 and 1.46.
    result || return_gvalue.get_value
  end

  def self.signal_connect(object, detailed_signal, data = nil, after = false, &block)
    raise ArgumentError, 'Block needed' unless block_given?
    signal_name, = detailed_signal.split('::')
    sig_info = object.class.find_signal signal_name

    closure = sig_info.wrap_in_closure do |*args|
      block.call(*args << data)
    end

    signal_connect_closure object, detailed_signal, closure, after
  end

  def self.signal_connect_after(object, detailed_signal, data = nil, &block)
    signal_connect object, detailed_signal, data, true, &block
  end

  # Smells of :reek:LongParameterList: due to the C interface.
  # rubocop:disable Metrics/ParameterLists
  def self.param_spec_int(name, nick, blurb, minimum, maximum, default_value, flags)
    ptr = Lib.g_param_spec_int(name, nick, blurb, minimum, maximum,
                               default_value, flags)
    ParamSpecInt.wrap(ptr)
  end

  load_class :Callback
  load_class :ClosureNotify
  load_class :ConnectFlags
  load_class :ClosureMarshal
  load_class :ParamFlags

  # NOTE: This Lib module is set up in `gir_ffi-base/gobject/lib.rb`.
  module Lib
    attach_function :g_object_ref_sink, [:pointer], :pointer
    attach_function :g_object_ref, [:pointer], :pointer
    attach_function :g_object_unref, [:pointer], :pointer

    attach_function :g_value_unset, [:pointer], :pointer

    attach_function :g_array_get_type, [], :size_t
    attach_function :g_byte_array_get_type, [], :size_t
    attach_function :g_hash_table_get_type, [], :size_t
    attach_function :g_strv_get_type, [], :size_t

    attach_function :g_signal_connect_data,
                    [:pointer, :string, Callback, :pointer, ClosureNotify, ConnectFlags],
                    :ulong
    attach_function :g_closure_set_marshal,
                    [:pointer, ClosureMarshal], :void

    attach_function :g_param_spec_int,
                    [:string, :string, :string, :int32, :int32, :int32, ParamFlags],
                    :pointer
  end

  TYPE_ARRAY = Lib.g_array_get_type
  TYPE_BYTE_ARRAY = Lib.g_byte_array_get_type
  TYPE_HASH_TABLE = Lib.g_hash_table_get_type
  TYPE_STRV = Lib.g_strv_get_type
end
