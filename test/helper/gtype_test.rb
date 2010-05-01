require File.expand_path('../helper.rb', File.dirname(__FILE__))
require 'girffi/helper/gtype'

class HelperGTypeTest < Test::Unit::TestCase
  context "The GType module" do
    should "have init as a public method" do
      assert_contains GirFFI::Helper::GType.public_methods, 'init'
    end

    should "not have g_type_init as a public method" do
      assert_does_not_contain GirFFI::Helper::GType.public_methods,
	'g_type_init'
    end

  end
  context "the init method" do
    should "not raise an error" do
      assert_nothing_raised do
	GirFFI::Helper::GType.init
      end
    end
  end
end
