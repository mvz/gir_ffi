require 'gir_ffi_test_helper'

describe GirFFI::TypeMap do
  describe ".type_specification_to_ffitype" do
    it "returns the nested FFI::Enum for an Enum module" do
      GirFFI::TypeMap.type_specification_to_ffitype(GLib::DateMonth).
        must_equal GLib::DateMonth::Enum
    end

    it "returns the nested FFI::Struct for an Struct module" do
      GirFFI::TypeMap.type_specification_to_ffitype(GObject::EnumValue).
        must_equal GObject::EnumValue::Struct
    end
  end
end
