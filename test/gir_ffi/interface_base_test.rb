require 'gir_ffi_test_helper'

describe GirFFI::InterfaceBase do
  describe "#wrap" do
    it "dynamically looks op the wrapped object's class" do
      mod = Module.new { extend GirFFI::InterfaceBase }

      mock(GirFFI::ArgHelper).object_pointer_to_object("some-pointer") { "good-result" }

      mod.wrap("some-pointer").must_equal "good-result"
    end
  end
end

