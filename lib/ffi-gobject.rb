GirFFI.setup :GObject

require 'ffi-gobject/value'
require 'ffi-gobject/initially_unowned'

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

  module Lib
    extend FFI::Library
    ffi_lib "gobject-2.0"
    attach_function :g_type_init, [], :void
    attach_function :g_object_ref, [:pointer], :void
    attach_function :g_object_ref_sink, [:pointer], :void
    attach_function :g_object_unref, [:pointer], :void
    attach_function :g_object_is_floating, [:pointer], :bool
  end
end
