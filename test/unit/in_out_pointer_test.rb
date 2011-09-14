require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/in_out_pointer'

describe GirFFI::InOutPointer do
  describe "an instance created with .from" do
    setup do
      @result = GirFFI::InOutPointer.from :gint32, 23
    end

    it "holds a pointer to the given value" do
      assert_equal 23, @result.get_int32(0)
    end

    it "is an instance of GirFFI::InOutPointer" do
      assert_instance_of GirFFI::InOutPointer, @result
    end
  end

  describe ".from" do
    it "handles :gboolean" do
      GirFFI::InOutPointer.from :gboolean, false
    end

    it "handles :utf8" do
      GirFFI::InOutPointer.from :utf8, "Hello"
    end
  end

  describe "an instance created with .from_array" do
    setup do
      @result = GirFFI::InOutPointer.from_array :gint32, [24, 13]
    end

    it "holds a pointer to a non-null pointer" do
      ptr = @result.read_pointer
      refute ptr.null?
    end

    it "holds a pointer to a pointer to the correct input values" do
      ptr = @result.read_pointer
      assert_equal [24, 13], [ptr.get_int(0), ptr.get_int(4)]
    end

    it "is an instance of GirFFI::InPointer" do
      assert_instance_of GirFFI::InOutPointer, @result
    end
  end

  describe ".from_array" do
    it "returns nil when passed nil" do
      result = GirFFI::InOutPointer.from_array :gint32, nil
      assert_nil result
    end
  end

  describe "an instance created with .from_array :utf8" do
    before do
      @result = GirFFI::InOutPointer.from_array :utf8, ["foo", "bar", "baz"]
    end

    it "returns a pointer to an array of pointers to strings" do
      ptr = @result.read_pointer
      ary = ptr.read_array_of_pointer(3)
      assert_equal ["foo", "bar", "baz"], ary.map {|p| p.read_string}
    end
  end

  describe "in instance created with .for" do
    setup do
      @result = GirFFI::InOutPointer.for :gint32
    end

    it "holds a pointer to a null value" do
      assert_equal 0, @result.get_int32(0)
    end

    it "is an instance of GirFFI::InOutPointer" do
      assert_instance_of GirFFI::InOutPointer, @result
    end
  end

  describe ".for" do
    it "handles :gboolean" do
      GirFFI::InOutPointer.for :gboolean
    end

    it "handles :utf8" do
      GirFFI::InOutPointer.for :utf8
    end
  end

  describe "#to_value" do
    it "returns the held value" do
      ptr = GirFFI::InOutPointer.from :gint32, 123
      assert_equal 123, ptr.to_value
    end

    describe "for :gboolean values" do
      it "works when the value is false" do
        ptr = GirFFI::InOutPointer.from :gboolean, false
        assert_equal false, ptr.to_value
      end

      it "works when the value is true" do
        ptr = GirFFI::InOutPointer.from :gboolean, true
        assert_equal true, ptr.to_value
      end
    end

    describe "for :utf8 values" do
      it "returns the held value" do
        ptr = GirFFI::InOutPointer.from :utf8, "Some value"
        assert_equal "Some value", ptr.to_value
      end
    end
  end
end
