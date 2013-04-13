require 'gir_ffi_test_helper'

describe GirFFI::ArgHelper do
  describe "::ptr_to_typed_array" do
    describe "for pointers to arrays of pointers to class types" do
      it "reads an array of pointers and wraps each in the class" do
        c = Class.new do
          def self.wrap a; "wrapped: #{a}"; end
        end

        mock(ptr = Object.new).read_array_of_pointer(2) { [:a, :b] }
        mock(ptr).null? { false }

        result = GirFFI::ArgHelper.ptr_to_typed_array [:pointer, c], ptr, 2

        assert_equal ["wrapped: a", "wrapped: b"], result
      end

      it "returns an empty array when passed a null pointer" do
        result = GirFFI::ArgHelper.ptr_to_typed_array [:pointer, Class.new], FFI::Pointer.new(0), 42
        result.must_equal []
      end

      it "returns an empty array when passed nil" do
        result = GirFFI::ArgHelper.ptr_to_typed_array [:pointer, Class.new], nil, 42
        result.must_equal []
      end
    end

    describe "for pointers to arrays of class types" do
      it "returns an empty array when passed a null pointer" do
        result = GirFFI::ArgHelper.ptr_to_typed_array Class.new, FFI::Pointer.new(0), 42
        result.must_equal []
      end

      it "returns an empty array when passed nil" do
        result = GirFFI::ArgHelper.ptr_to_typed_array Class.new, nil, 42
        result.must_equal []
      end
    end

    describe "for pointers to string arrays" do
      it "returns an empty array when passed a null pointer" do
        result = GirFFI::ArgHelper.ptr_to_typed_array :utf8, FFI::Pointer.new(0), 42
        result.must_equal []
      end

      it "returns an empty array when passed nil" do
        result = GirFFI::ArgHelper.ptr_to_typed_array :utf8, nil, 42
        result.must_equal []
      end
    end

    describe "for pointers to arrays of base types" do
      it "returns an empty array when passed a null pointer" do
        result = GirFFI::ArgHelper.ptr_to_typed_array :gint32, FFI::Pointer.new(0), 0
        result.must_equal []
      end

      it "returns an empty array when passed nil" do
        result = GirFFI::ArgHelper.ptr_to_typed_array :gint32, nil, 0
        result.must_equal []
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

    describe "when called with a string" do
      it "stores the string in GirFFI::ArgHelper::OBJECT_STORE" do
        str = "Foo"
        ptr = GirFFI::ArgHelper.object_to_inptr(str)
        result = GirFFI::ArgHelper::OBJECT_STORE[ptr.address]
        result.must_equal str
      end
    end
  end

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
