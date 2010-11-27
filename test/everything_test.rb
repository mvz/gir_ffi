require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

# Tests generated methods and functions in the Everything namespace.
class EverythingTest < Test::Unit::TestCase
  context "The generated Everything module" do
    setup do
      GirFFI.setup :Everything
    end

    should "have correct test_boolean" do
      assert_equal false, Everything.test_boolean(false)
      assert_equal true, Everything.test_boolean(true)
    end

    should "have correct test_callback_user_data" do
      a = :foo
      result = Everything.test_callback_user_data Proc.new {|u|
	a = u
	5
      }, :bar
      assert_equal :bar, a
      assert_equal 5, result
    end

    should "have correct test_gtype" do
      result = Everything.test_gtype 23
      assert_equal 23, result
    end

    should "have correct test_value_return" do
      result = Everything.test_value_return 3423
      assert_equal 3423, result.get_int
    end

    context "the Everything::TestBoxed class" do
      should "create an instance using #new" do
	tb = Everything::TestBoxed.new
	assert_instance_of Everything::TestBoxed, tb
      end

      should "allow creating an instance using alternative constructors" do
	tb = Everything::TestBoxed.new_alternative_constructor1 1
	assert_instance_of Everything::TestBoxed, tb
	assert_equal 1, tb[:some_int8]

	tb = Everything::TestBoxed.new_alternative_constructor2 1, 2
	assert_instance_of Everything::TestBoxed, tb
	assert_equal 1 + 2, tb[:some_int8]

	tb = Everything::TestBoxed.new_alternative_constructor3 "54"
	assert_instance_of Everything::TestBoxed, tb
	assert_equal 54, tb[:some_int8]
      end

      should "have a working equals method" do
	tb = Everything::TestBoxed.new_alternative_constructor1 123
	tb2 = Everything::TestBoxed.new_alternative_constructor2 120, 3
	assert_equal true, tb.equals(tb2)
      end

      should "have a working copy method" do
	tb = Everything::TestBoxed.new_alternative_constructor1 123
	tb2 = tb.copy
	assert_instance_of Everything::TestBoxed, tb2
	assert_equal 123, tb2[:some_int8], "fields copied"
	tb2[:some_int8] = 89
	assert_equal 123, tb[:some_int8], "is a true copy"
      end
    end

    context "the Everything::TestEnum type" do
      should "be of type FFI::Enum" do
	assert_instance_of FFI::Enum, Everything::TestEnum
      end
    end

    context "the Everything::TestSimpleBoxedA class" do
      setup do
	GirFFI::Builder.build_class 'Everything', 'TestSimpleBoxedA'
      end

      should "set have a working new method" do
	assert Everything::TestSimpleBoxedA.respond_to? "new"
      end
    end

  end

end
