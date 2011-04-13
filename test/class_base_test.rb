require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class ClassBaseTest < MiniTest::Spec
  context "A class derived from GirFFI::Base" do
    # TODO: See if we can test some part of Base again.
    should "pass" do
      assert true
    end
  end
end
