require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

describe GirFFI::IBaseInfo do
  describe "#safe_name" do
    it "makes names starting with an underscore safe" do
      stub(ptr = Object.new).null? { false }

      info = GirFFI::IBaseInfo.wrap ptr

      stub(info).name { "_foo" }

      assert_equal "Private___foo", info.safe_name
    end
  end
end

