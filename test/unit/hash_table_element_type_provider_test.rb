require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::HashTableElementTypeProvider do
  describe "#elm_t" do
    it "returns a string with an array of the first two subtype tags" do
      builder = Object.new
      builder.extend GirFFI::Builder::HashTableElementTypeProvider

      stub(builder).subtype_tag(0) { :foo }
      stub(builder).subtype_tag(1) { :bar }

      assert_equal "[:foo, :bar]", builder.elm_t
    end
  end
end

