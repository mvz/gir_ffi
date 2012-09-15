require 'introspection_test_helper'

describe GObjectIntrospection::IBaseInfo do
  describe "#safe_name" do
    it "makes names starting with an underscore safe" do
      stub(ptr = Object.new).null? { false }

      info = GObjectIntrospection::IBaseInfo.wrap ptr

      stub(info).name { "_foo" }

      assert_equal "Private___foo", info.safe_name
    end
  end
end

