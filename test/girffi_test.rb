require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class GirFFITest < Test::Unit::TestCase
  context "GirFFI" do
    should "be able to set up cairo" do
      assert_nothing_raised {
        GirFFI.setup :cairo
      }
    end
  end
end

