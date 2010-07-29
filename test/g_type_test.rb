require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi/g_type'

class HelperGTypeTest < Test::Unit::TestCase
  context "The GType module" do
    should "have init as a public method" do
      assert GirFFI::GType.respond_to?('init')
    end

    should "not have g_type_init as a public method" do
      assert GirFFI::GType.respond_to?('g_type_init') == false
    end

  end
  context "the init method" do
    should "not raise an error" do
      assert_nothing_raised do
	GirFFI::GType.init
      end
    end
  end
end
