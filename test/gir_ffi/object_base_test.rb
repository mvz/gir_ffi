require 'gir_ffi_test_helper'

describe GirFFI::ObjectBase do
  let(:derived_class) { Class.new GirFFI::ObjectBase }
  describe ".wrap" do
    it "delegates conversion to the wrapped pointer" do
      mock(ptr = Object.new).to_object { "good-result" }
      derived_class.wrap(ptr).must_equal "good-result"
    end
  end

  describe ".to_ffitype" do
    it "returns :pointer" do
      derived_class.to_ffitype.must_equal :pointer
    end
  end
end


