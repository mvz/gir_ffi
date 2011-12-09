require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::ListTypesProvider do
  describe "#elm_t" do
    it "returns a string with just the first subtype tag" do
      stub(subtype0 = Object.new).tag { :foo }
      stub(type = Object.new).param_type(0) { subtype0 }

      provider = GirFFI::Builder::ListTypesProvider.new type

      assert_equal ":foo", provider.elm_t
    end
  end

  describe "#subtype_tag" do
    it "returns :gpointer if the param_type is a pointer with tag :void" do
      stub(subtype0 = Object.new).tag { :void }
      stub(subtype0).pointer? { true }
      stub(type = Object.new).param_type(0) { subtype0 }

      provider = GirFFI::Builder::ListTypesProvider.new type

      assert_equal :gpointer, provider.subtype_tag
    end
  end
end
