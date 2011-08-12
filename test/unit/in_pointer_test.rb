require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/in_pointer'

describe GirFFI::InPointer do
  describe ".from_array" do
    it "returns nil when passed nil" do
      result = GirFFI::InPointer.from_array :gint32, nil
      assert { result.nil? }
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
      assert { @result.is_a? GirFFI::InPointer }
    end
  end
end

