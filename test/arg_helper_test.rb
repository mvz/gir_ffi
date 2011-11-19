require File.expand_path('gir_ffi_test_helper.rb', File.dirname(__FILE__))

class ArgHelperTest < MiniTest::Spec
  context "The object_to_inptr method" do
    context "when called with an object implementing to_ptr" do
      should "return the result of to_ptr" do
	obj = Object.new
	def obj.to_ptr; :test_value; end
	assert_equal :test_value, GirFFI::ArgHelper.object_to_inptr(obj)
      end
    end

    context "when called with nil" do
      should "return nil" do
	assert_equal nil, GirFFI::ArgHelper.object_to_inptr(nil)
      end
    end
  end

  describe "::object_pointer_to_object" do
    it "finds the wrapping class by gtype and wraps the pointer in it" do
      klsptr = GirFFI::InOutPointer.from :gtype, 0xdeadbeef
      objptr = GirFFI::InOutPointer.from :pointer, klsptr

      object_class = Class.new
      mock(GirFFI::Builder).build_by_gtype(0xdeadbeef) { object_class }
      mock(object_class).wrap(objptr) { "good-result" }

      r = GirFFI::ArgHelper.object_pointer_to_object objptr
      assert_equal "good-result", r
    end
  end
end
