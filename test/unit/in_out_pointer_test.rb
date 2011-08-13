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
end
