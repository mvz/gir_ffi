require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

describe GObjectIntrospection::IFunctionInfo do
  describe "#safe_name" do
    it "keeps lower case names lower case" do
      stub(ptr = Object.new).null? { false }

      info = GObjectIntrospection::IFunctionInfo.wrap ptr

      stub(info).name { "foo" }

      assert_equal "foo", info.safe_name
    end
  end
end


