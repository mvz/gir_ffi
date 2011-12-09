require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::HashTableTypesProvider do
  describe "#elm_t" do
    it "returns a string with an array of the first two subtype tags" do
      stub(subtype0 = Object.new).tag { :foo }
      stub(subtype1 = Object.new).tag { :bar }
      type = Object.new
      stub(type).param_type(0) { subtype0 }
      stub(type).param_type(1) { subtype1 }

      provider = GirFFI::Builder::HashTableTypesProvider.new type

      assert_equal "[:foo, :bar]", provider.elm_t
    end
  end
end

