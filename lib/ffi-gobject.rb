# frozen_string_literal: true

require "gir_ffi/core"

# Bypass check for existing modules
GirFFI::Builders::ModuleBuilder.new("GObject").generate

require "ffi-gobject/value"
require "ffi-gobject/initially_unowned"
require "ffi-gobject/closure"
require "ffi-gobject/object"
require "ffi-gobject/object_class"
require "ffi-gobject/param_spec"
require "ffi-gobject/ruby_closure"
require "gir_ffi/signal_not_found_error"

# Module representing GLib's GObject namespace.
module GObject
  def self.type_from_instance_pointer(inst_ptr)
    return nil if inst_ptr.null?

    klsptr = inst_ptr.get_pointer 0
    klsptr.get_gtype 0
  end

  def self.type_from_instance(instance)
    type_from_instance_pointer instance.to_ptr
  end

  def self.type_name_from_instance(instance)
    type_name type_from_instance instance
  end

  def self.signal_lookup_from_instance(signal, object)
    signal_lookup signal, type_from_instance(object)
  end

  def self.signal_emit(object, detailed_signal, *args)
    _, signal_name, detail = process_detailed_signal detailed_signal

    signal_id = signal_lookup_from_instance signal_name, object
    detail_quark = GLib.quark_from_string(detail)

    sig_info = object.class.find_signal signal_name
    argument_gvalues = sig_info.arguments_to_gvalues object, args
    return_gvalue = sig_info.gvalue_for_return_value

    signal_emitv argument_gvalues, signal_id, detail_quark, return_gvalue
  end

  def self.signal_connect(object, detailed_signal, data = nil, after = false, &block)
    block or raise ArgumentError, "Block needed"

    detailed_signal, signal_name, = process_detailed_signal detailed_signal

    sig_info = object.class.find_signal signal_name
    closure = sig_info.wrap_in_closure do |*args|
      yield(*args << data)
    end

    signal_connect_closure object, detailed_signal, closure, after
  end

  def self.signal_connect_after(object, detailed_signal, data = nil, &)
    signal_connect(object, detailed_signal, data, true, &)
  end

  class << self
    private

    def process_detailed_signal(detailed_signal)
      detailed_signal = detailed_signal.to_s.tr("_", "-") if detailed_signal.is_a?(Symbol)
      signal_name, detail = detailed_signal.split("::")
      return detailed_signal, signal_name, detail
    end
  end

  load_class :Callback
  load_class :ClosureNotify
  load_class :ConnectFlags
  load_class :ClosureMarshal
  load_class :ParamFlags

  # Attach some needed functions to the GObject Lib, which was set up in
  # `gir_ffi-base/gobject/lib.rb`.
  Lib.class_eval do
    attach_function :g_object_ref_sink, [:pointer], :pointer
    attach_function :g_object_ref, [:pointer], :pointer
    attach_function :g_object_unref, [:pointer], :pointer

    attach_function :g_value_copy, [:pointer, :pointer], :void
    attach_function :g_value_unset, [:pointer], :pointer

    attach_function :g_signal_connect_data,
                    [:pointer, :string, Callback, :pointer, ClosureNotify, ConnectFlags],
                    :ulong

    attach_function :g_closure_ref, [:pointer], :pointer
    attach_function :g_closure_sink, [:pointer], :pointer
    attach_function :g_closure_set_marshal,
                    [:pointer, ClosureMarshal], :void

    attach_function :g_param_spec_ref, [:pointer], :pointer
    attach_function :g_param_spec_sink, [:pointer], :pointer
  end
end
