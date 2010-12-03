require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

# Tests generated methods and functions in the Everything namespace.
class EverythingTest < Test::Unit::TestCase
  context "The generated Everything module" do
    setup do
      GirFFI.setup :Everything
    end

    context "the Everything::TestBoxed class" do
      should "create an instance using #new" do
	tb = Everything::TestBoxed.new
	assert_instance_of Everything::TestBoxed, tb
      end

      should "create an instance using #new_alternative_constructor1" do
	tb = Everything::TestBoxed.new_alternative_constructor1 1
	assert_instance_of Everything::TestBoxed, tb
	assert_equal 1, tb[:some_int8]
      end

      should "create an instance using #new_alternative_constructor2" do
	tb = Everything::TestBoxed.new_alternative_constructor2 1, 2
	assert_instance_of Everything::TestBoxed, tb
	assert_equal 1 + 2, tb[:some_int8]
      end

      should "create an instance using #new_alternative_constructor3" do
	tb = Everything::TestBoxed.new_alternative_constructor3 "54"
	assert_instance_of Everything::TestBoxed, tb
	assert_equal 54, tb[:some_int8]
      end

      context "an instance" do
	setup do
	  @tb = Everything::TestBoxed.new_alternative_constructor1 123
	end

	should "have a working equals method" do
	  tb2 = Everything::TestBoxed.new_alternative_constructor2 120, 3
	  assert_equal true, @tb.equals(tb2)
	end

	context "its copy method" do
	  setup do
	    @tb2 = @tb.copy
	  end

	  should "return an instance of TestBoxed" do
	    assert_instance_of Everything::TestBoxed, @tb2
	  end

	  should "copy fields" do
	    assert_equal 123, @tb2[:some_int8]
	  end

	  should "create a true copy" do
	    @tb[:some_int8] = 89
	    assert_equal 123, @tb2[:some_int8]
	  end
	end
      end
    end

    context "the Everything::TestEnum type" do
      should "be of type FFI::Enum" do
	assert_instance_of FFI::Enum, Everything::TestEnum
      end
    end

    context "the Everything::TestObj class" do
      should "create an instance using #new_from_file" do
	o = Everything::TestObj.new_from_file("foo")
	assert_instance_of Everything::TestObj, o
      end

      should "create an instance using #new_callback" do
	o = Everything::TestObj.new_callback Proc.new { }, nil, nil
	assert_instance_of Everything::TestObj, o
      end

      should "have a working #static_method" do
	rv = Everything::TestObj.static_method 623
	assert_equal 623.0, rv
      end

      should "have a working #static_method_callback" do
	a = 1
	Everything::TestObj.static_method_callback Proc.new { a = 2 }
	assert_equal 2, a
      end

      context "an instance" do
	setup do
	  @o = Everything::TestObj.new_from_file("foo")
	end

	should "have a working #torture_signature_0 method" do
	  y, z, q = @o.torture_signature_0(-21, "hello", 13)
	  assert_equal [-21, 2 * -21, "hello".length + 13],
	    [y, z, q]
	end

	context "its #torture_signature_1 method" do
	  should "work for m even" do
	    ret, y, z, q = @o.torture_signature_1(-21, "hello", 12)
	    assert_equal [true, -21, 2 * -21, "hello".length + 12],
	      [ret, y, z, q]
	  end

	  should "throw an exception for m odd" do
	    assert_raises RuntimeError do
	      @o.torture_signature_1(-21, "hello", 11)
	    end
	  end
	end
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

  end

end
