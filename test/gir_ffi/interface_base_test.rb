require 'gir_ffi_test_helper'

describe GirFFI::InterfaceBase do
  describe "#wrap" do
    it "delegates conversion to the wrapped pointer" do
      mod = Module.new { extend GirFFI::InterfaceBase }
      mock(ptr = Object.new).to_object { "good-result" }
      mod.wrap(ptr).must_equal "good-result"
    end
  end
end

