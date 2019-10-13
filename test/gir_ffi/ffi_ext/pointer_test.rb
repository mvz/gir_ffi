# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::FFIExt::Pointer do
  let(:pointer_class) { Class.new { include GirFFI::FFIExt::Pointer } }
  describe "#to_object" do
    it "finds the wrapping class by gtype and wraps the pointer in it" do
      ptr = pointer_class.new
      expect(ptr).to receive(:null?).and_return false
      object_class = Class.new

      expect(GObject).to receive(:type_from_instance_pointer).with(ptr).and_return 0xdeadbeef
      expect(GirFFI::Builder).to receive(:build_by_gtype).with(0xdeadbeef).and_return object_class
      expect(object_class).to receive(:direct_wrap).with(ptr).and_return "good-result"

      _(ptr.to_object).must_equal "good-result"
    end
  end
end
