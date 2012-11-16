require 'gir_ffi_test_helper'

describe GirFFI::Builder::Argument::Base do
  describe "#subtype_tag_or_class_name" do
    it "delegates to the type" do
      mock(info = Object.new).subtype_tag_or_class_name { 'foo' }

      builder = GirFFI::Builder::Argument::Base.new nil, 'bar', info, :direction
      assert_equal "foo", builder.subtype_tag_or_class_name
    end
  end
end

