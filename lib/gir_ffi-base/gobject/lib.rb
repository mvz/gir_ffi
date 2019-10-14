# frozen_string_literal: true

require "ffi/bit_masks"

module GObject
  # Module for attaching functions from the gobject library
  module Lib
    extend FFI::Library
    extend FFI::BitMasks
    ffi_lib "gobject-2.0"
    attach_function :g_type_from_name, [:string], :size_t
    attach_function :g_type_fundamental, [:size_t], :size_t
    attach_function :g_array_get_type, [], :size_t
    attach_function :g_byte_array_get_type, [], :size_t
    attach_function :g_error_get_type, [], :size_t
    attach_function :g_hash_table_get_type, [], :size_t
    attach_function :g_strv_get_type, [], :size_t
  end
end
