require 'test_helper'

describe GObjectIntrospection::IFunctionInfo do
  describe "#safe_name" do
    it "keeps lower case names lower case" do
      stub(ptr = Object.new).null? { false }
      info = GObjectIntrospection::IFunctionInfo.wrap ptr
      stub(info).name { "foo" }

      assert_equal "foo", info.safe_name
    end

    it "returns a non-empty string if name is empty" do
      stub(ptr = Object.new).null? { false }
      info = GObjectIntrospection::IFunctionInfo.wrap ptr
      stub(info).name { "" }

      assert_equal "_", info.safe_name
    end
  end
end


