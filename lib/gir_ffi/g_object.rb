require 'ffi'

module GirFFI
  # TODO: Rename to avoid constant lookup issues (and confusion).
  module GObject
    def self.type_init
      Lib::g_type_init
    end

    def self.object_ref o
      Lib::g_object_ref o.to_ptr
    end

    def self.object_ref_sink o
      Lib::g_object_ref_sink o.to_ptr
    end

    def self.object_unref o
      Lib::g_object_unref o.to_ptr
    end

    def self.object_is_floating o
      Lib::g_object_is_floating o.to_ptr
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
end


