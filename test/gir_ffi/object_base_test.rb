require 'gir_ffi_test_helper'

describe GirFFI::ObjectBase do
  describe "#wrap" do
    it "delegates conversion to the wrapped pointer" do
      mod = Class.new GirFFI::ObjectBase
      mock(ptr = Object.new).to_object { "good-result" }
      mod.wrap(ptr).must_equal "good-result"
    end
  end
end


