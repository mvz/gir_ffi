require 'gir_ffi_test_helper'

describe GirFFI::ArgHelper do
  describe "::object_pointer_to_object" do
    it "finds the wrapping class by gtype and wraps the pointer in it" do
      klsptr = GirFFI::InOutPointer.from :GType, 0xdeadbeef
      objptr = GirFFI::InOutPointer.from :pointer, klsptr

      object_class = Class.new
      mock(GirFFI::Builder).build_by_gtype(0xdeadbeef) { object_class }
      mock(object_class).direct_wrap(objptr) { "good-result" }

      r = GirFFI::ArgHelper.object_pointer_to_object objptr
      assert_equal "good-result", r
    end
  end
end
