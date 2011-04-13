require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class GirFFITest < MiniTest::Spec
  context "GirFFI" do
    should "be able to set up cairo" do
      assert_nothing_raised {
        GirFFI.setup :cairo
      }
    end

    it "sets up dependencies" do
      cleanup_module :GObject
      cleanup_module :Regress
      GirFFI.setup :Regress
      assert Object.const_defined?(:GObject), "GObject should be defined, but isn't"
    end
  end
end

