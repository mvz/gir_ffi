require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

class HelperGTypeTest < Test::Unit::TestCase
  context "The GType module" do
    should "have init as a public method" do
      assert_contains GIRepository::Helper::GType.public_methods, 'init'
    end

    should "not have g_type_init as a public method" do
      assert_does_not_contain GIRepository::Helper::GType.public_methods,
	'g_type_init'
    end

  end
  context "the init method" do
    should "not raise an error" do
      assert_nothing_raised do
	GIRepository::Helper::GType.init
      end
    end
  end
end
