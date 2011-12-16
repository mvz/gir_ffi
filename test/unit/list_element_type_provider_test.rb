require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::ListElementTypeProvider do
  describe "#elm_t" do
    it "returns a string with just the first subtype tag" do
      builder = Object.new
      builder.extend GirFFI::Builder::ListElementTypeProvider
      mock(builder).subtype_tag { :foo }

      assert_equal ":foo", builder.elm_t
    end
  end
end
