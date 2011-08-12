require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/in_pointer'

describe GirFFI::InPointer do
  describe "an instance created with #from_array" do
    setup do
      @result = GirFFI::InPointer.from_array :gint32, [24, 13]
    end

    it "holds a pointer to the correct input values" do
      assert_equal 24, @result.get_int(0)
      assert_equal 13, @result.get_int(4)
    end
  end
end

