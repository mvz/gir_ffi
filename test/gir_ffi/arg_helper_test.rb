require 'gir_ffi_test_helper'

describe GirFFI::ArgHelper do
  describe ".cast_from_pointer" do
    it "handles class types" do
      klass = Class.new
      mock(klass).wrap(:pointer_value) { :wrapped_value }
      GirFFI::ArgHelper.cast_from_pointer(klass, :pointer_value).must_equal :wrapped_value
    end
  end
end
