require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/in_pointer'

describe GirFFI::InPointer do
  describe ".from_array" do
    it "returns nil when passed nil" do
      result = GirFFI::InPointer.from_array :gint32, nil
      assert_nil result
    end

    it "handles type tag :gtype" do
      GirFFI::InPointer.from_array :gtype, [2]
    end

    it "handles type tag :interface_pointer" do
      GirFFI::InPointer.from_array :interface_pointer, []
    end
  end

  describe "an instance created with .from_array" do
    setup do
      @result = GirFFI::InPointer.from_array :gint32, [24, 13]
    end

    it "holds a pointer to the correct input values" do
      assert_equal 24, @result.get_int(0)
      assert_equal 13, @result.get_int(4)
    end

    it "is an instance of GirFFI::InPointer" do
      assert_instance_of GirFFI::InPointer, @result
    end
  end

  describe "an instance created with .from_array :utf8" do
    before do
      @result = GirFFI::InPointer.from_array :utf8, ["foo", "bar", "baz"]
    end

    it "returns an array of pointers to strings" do
      ary = @result.read_array_of_pointer(3)
      assert_equal ["foo", "bar", "baz"], ary.map {|p| p.read_string}
    end
  end

  describe "an instance created with .from :utf8" do
    before do
      @result = GirFFI::InPointer.from :utf8, "foo"
    end

    it "returns an pointers to the given string" do
      ary = @result.read_array_of_pointer(3)
      assert_equal "foo", @result.read_string
    end

    it "is an instance of GirFFI::InPointer" do
      assert_instance_of GirFFI::InPointer, @result
    end
  end

  describe ".from" do
    it "returns nil when passed nil" do
      result = GirFFI::InPointer.from :foo, nil
      assert_nil result
    end
  end
end

