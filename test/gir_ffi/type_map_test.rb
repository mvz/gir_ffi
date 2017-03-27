# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::TypeMap do
  describe '.type_specification_to_ffi_type' do
    it 'returns the nested FFI::Enum for an Enum module' do
      GirFFI::TypeMap.type_specification_to_ffi_type(GLib::DateMonth).
        must_equal GLib::DateMonth
    end

    it 'returns the class itself for a Struct class' do
      GirFFI::TypeMap.type_specification_to_ffi_type(GObject::EnumValue).
        must_equal GObject::EnumValue
    end
  end
end
