require 'gir_ffi_test_helper'

describe GirFFI::InterfaceBase do
  let(:interface) { Module.new { extend GirFFI::InterfaceBase } }

  describe "#wrap" do
    it "delegates conversion to the wrapped pointer" do
      mock(ptr = Object.new).to_object { "good-result" }
      interface.wrap(ptr).must_equal "good-result"
    end
  end

  describe ".to_ffitype" do
    it "returns :pointer" do
      interface.to_ffitype.must_equal :pointer
    end
  end
end
