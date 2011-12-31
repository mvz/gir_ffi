require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::ArgHelper do
  describe "::ptr_to_typed_array" do
    describe "for pointers to class types" do
      it "reads an array of pointers and wraps each in the class" do
        c = Class.new do
          def self.wrap a; "wrapped: #{a}"; end
        end

        mock(ptr = Object.new).read_array_of_pointer(2) { [:a, :b] }

        result = GirFFI::ArgHelper.ptr_to_typed_array [:pointer, c], ptr, 2

        assert_equal ["wrapped: a", "wrapped: b"], result
      end
    end
  end

  describe "#object_to_inptr" do
    describe "when called with an object implementing to_ptr" do
      it "returns the result of to_ptr" do
	obj = Object.new
	def obj.to_ptr; :test_value; end
	assert_equal :test_value, GirFFI::ArgHelper.object_to_inptr(obj)
      end
    end

    describe "when called with nil" do
      it "returns nil" do
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
