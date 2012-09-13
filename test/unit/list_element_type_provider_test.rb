require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::ListElementTypeProvider do
  describe "#elm_t" do
    it "returns a string with just the first subtype tag" do
      builder = Object.new
      builder.extend GirFFI::Builder::ListElementTypeProvider

      mock(type_info = Object.new).element_type { :foo }
      mock(builder).type_info { type_info }

      assert_equal ":foo", builder.elm_t
    end
  end
end
