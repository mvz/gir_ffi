require 'gir_ffi_test_helper'

describe GirFFI::FFIExt::Pointer do
  let(:klass) { Class.new { include GirFFI::FFIExt::Pointer } }
  describe "#to_object" do
    it "finds the wrapping class by gtype and wraps the pointer in it" do
      ptr = klass.new
      mock(ptr).null? { false }
      object_class = Class.new

      mock(GObject).type_from_instance_pointer(ptr) { 0xdeadbeef }
      mock(GirFFI::Builder).build_by_gtype(0xdeadbeef) { object_class }
      mock(object_class).direct_wrap(ptr) { "good-result" }

      ptr.to_object.must_equal "good-result"
    end
  end
end
