require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/in_out_pointer'

describe GirFFI::InOutPointer do
  describe "in instance created with .for" do
    setup do
      @result = GirFFI::InOutPointer.for :gint32, 23
    end

    it "holds a pointer to the given value" do
      assert { @result.read_int32 == 23 }
    end

    it "is an instance of GirFFI::InOutPointer" do
      assert { @result.is_a? GirFFI::InOutPointer }
    end
  end
end
