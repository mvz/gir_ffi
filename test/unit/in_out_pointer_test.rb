require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/in_out_pointer'

describe GirFFI::InOutPointer do
  describe "an instance created with .from" do
    setup do
      @result = GirFFI::InOutPointer.from :gint32, 23
    end

    it "holds a pointer to the given value" do
      assert { @result.read_int32 == 23 }
    end

    it "is an instance of GirFFI::InOutPointer" do
      assert { @result.is_a? GirFFI::InOutPointer }
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
      deny { ptr.null? }
    end

    it "holds a pointer to a pointer to the correct input values" do
      ptr = @result.read_pointer
      assert {
        ptr.get_int(0) == 24 &&
        ptr.get_int(4) == 13
      }
    end

    it "is an instance of GirFFI::InPointer" do
      assert { @result.is_a? GirFFI::InOutPointer }
    end
  end

  describe ".from_array" do
    it "returns nil when passed nil" do
      result = GirFFI::InOutPointer.from_array :gint32, nil
      assert { result.nil? }
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

  describe "#to_value" do
    it "returns the held value" do
      ptr = GirFFI::InOutPointer.from :gint32, 123
      assert { ptr.to_value == 123 }
    end
  end
end
