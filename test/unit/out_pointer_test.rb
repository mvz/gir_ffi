require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/out_pointer'

describe GirFFI::OutPointer do
  describe "in instance created with .for" do
    setup do
      @result = GirFFI::OutPointer.for :gint32
    end

    it "holds a pointer to a null value" do
      assert { @result.read_int32 == 0 }
    end

    it "is an instance of GirFFI::OutPointer" do
      assert { @result.is_a? GirFFI::OutPointer }
    end
  end
end
