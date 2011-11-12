# coding: utf-8
require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

# Tests generated methods and functions in the Regress namespace.
class GeneratedRegressTest < MiniTest::Spec
  context "The generated Regress module" do
    setup do
      GirFFI.setup :Regress
    end

    it "has the constant DOUBLE_CONSTANT" do
      assert_equal 44.22, Regress::DOUBLE_CONSTANT
    end

    it "has the constant INT_CONSTANT" do
      assert_equal 4422, Regress::INT_CONSTANT
    end

    it "has the constant Mixed_Case_Constant" do
      assert_equal 4423, Regress::Mixed_Case_Constant
    end

    it "has the constant STRING_CONSTANT" do
      assert_equal "Some String", Regress::STRING_CONSTANT
    end

    context "the Regress::TestBoxed class" do
      should "create an instance using #new" do
	tb = Regress::TestBoxed.new
	assert_instance_of Regress::TestBoxed, tb
      end

      should "create an instance using #new_alternative_constructor1" do
	tb = Regress::TestBoxed.new_alternative_constructor1 1
	assert_instance_of Regress::TestBoxed, tb
	assert_equal 1, tb[:some_int8]
      end

      should "create an instance using #new_alternative_constructor2" do
	tb = Regress::TestBoxed.new_alternative_constructor2 1, 2
	assert_instance_of Regress::TestBoxed, tb
	assert_equal 1 + 2, tb[:some_int8]
      end

      should "create an instance using #new_alternative_constructor3" do
	tb = Regress::TestBoxed.new_alternative_constructor3 "54"
	assert_instance_of Regress::TestBoxed, tb
	assert_equal 54, tb[:some_int8]
      end

      should "have non-zero positive result for #get_gtype" do
	assert Regress::TestBoxed.get_gtype > 0
      end

      context "an instance" do
	setup do
	  @tb = Regress::TestBoxed.new_alternative_constructor1 123
	end

	should "have a working equals method" do
	  tb2 = Regress::TestBoxed.new_alternative_constructor2 120, 3
	  assert_equal true, @tb.equals(tb2)
	end

	context "its copy method" do
	  setup do
	    @tb2 = @tb.copy
	  end

	  should "return an instance of TestBoxed" do
	    assert_instance_of Regress::TestBoxed, @tb2
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

    context "the Regress::TestEnum type" do
      should "be of type FFI::Enum" do
	assert_instance_of FFI::Enum, Regress::TestEnum
      end
    end

    it "has the bitfield TestFlags" do
      assert_equal 1, Regress::TestFlags[:flag1]
      assert_equal 2, Regress::TestFlags[:flag2]
      assert_equal 4, Regress::TestFlags[:flag3]
    end

    context "the Regress::TestFloating class" do
      context "an instance" do
	setup do
	  @o = Regress::TestFloating.new
	end

	should "have a reference count of 1" do
	  assert_equal 1, ref_count(@o)
	end

	should "have been sunk" do
	  assert !is_floating?(@o)
	end
      end
    end

    describe "TestFundamentalObject" do
      it "must exist" do
        Regress::TestFundamentalObject
      end

      it "does not have GObject::Object as an ancestor" do
        refute_includes Regress::TestFundamentalObject.ancestors,
          GObject::Object
      end
      # TODO: Test more, if possible (e.g., cannot be instantiated).
    end

    describe "TestFundamentalSubObject" do
      before do
        @so = Regress::TestFundamentalSubObject.new "foo"
      end

      it "can be instantiated" do
        pass
      end

      it "is a subclass of TestFundamentalObject" do
        assert_kind_of Regress::TestFundamentalObject, @so
      end

      it "stores the constructor parameter in the :data field" do
        assert_equal "foo", @so[:data].read_string
      end

      it "has a refcount of 1" do
        assert_equal 1, @so[:fundamental_object][:refcount]
      end
    end

    describe "TestInterface" do
      it "is a module" do
        assert_instance_of Module, Regress::TestInterface
      end

      it "extends InterfaceBase" do
        metaclass = class << Regress::TestInterface; self; end
        assert_includes metaclass.ancestors, GirFFI::InterfaceBase
      end
    end

    context "the Regress::TestObj class" do
      should "create an instance using #new_from_file" do
	o = Regress::TestObj.new_from_file("foo")
	assert_instance_of Regress::TestObj, o
      end

      # TODO: Test that callback is called
      should "create an instance using #new_callback" do
	o = Regress::TestObj.new_callback Proc.new { }, nil, nil
	assert_instance_of Regress::TestObj, o
      end

      should "have a working #static_method" do
	rv = Regress::TestObj.static_method 623
	assert_equal 623.0, rv
      end

      context "#static_method_callback" do
        should "work when called with a Proc" do
          a = 1
          Regress::TestObj.static_method_callback Proc.new { a = 2 }
          assert_equal 2, a
        end

        should "work when called with nil" do
          assert_nothing_raised do
            Regress::TestObj.static_method_callback nil
          end
        end
      end

      context "an instance" do
	setup do
	  @o = Regress::TestObj.new_from_file("foo")
	end

        describe "its gtype" do
          it "can be found through get_gtype and GObject.type_from_instance" do
            gtype = Regress::TestObj.get_gtype
            r = GObject.type_from_instance @o
            assert_equal gtype, r
          end
        end

        describe "#get_property" do
          it "gets the 'bare' property" do
            obj = Regress::TestObj.new_from_file("bar")
            @o.set_bare obj

            obj2 = @o.get_property("bare")

            assert_equal obj.to_ptr, obj2.to_ptr
            assert_instance_of Regress::TestObj, obj2
          end

          it "gets the 'boxed' property" do
            tb = Regress::TestBoxed.new_alternative_constructor1 75
            @o[:boxed] = tb

            tb2 = @o.get_property("boxed")

            assert_instance_of Regress::TestBoxed, tb2
            assert_equal 75, tb2[:some_int8]
          end

          it "gets the 'hash-table' property" do
            ht = GLib::HashTable.new :utf8, :gint8
            ht.insert "foo", 34
            ht.insert "bar", 83

            @o[:hash_table] = ht

            ht2 = @o.get_property "hash-table"
            assert_equal({"foo" => 34, "bar" => 83}, ht2.to_hash)
          end

          it "gets the 'float' property" do
            @o[:some_float] = 3.14
            assert_in_epsilon 3.14, @o.get_property("float")
          end

          it "gets the 'double' property" do
            @o[:some_double] = 3.14
            assert_in_epsilon 3.14, @o.get_property("double")
          end

          it "gets the 'int' property" do
            @o[:some_int8] = 42
            assert_equal 42, @o.get_property("int")
          end

          it "gets the 'list' property" do
            lst = GLib::List.new(:utf8).append("foo").append("bar")

            @o[:list] = lst

            lst2 = @o.get_property "list"
            assert_equal ["foo", "bar"], lst2.to_a
          end

        end

	should "have a reference count of 1" do
	  assert_equal 1, ref_count(@o)
	end

	should "not float" do
	  assert !is_floating?(@o)
	end

	should "have a working (virtual) #matrix method" do
	  rv = @o.matrix "bar"
	  assert_equal 42, rv
	end

	should "have a working #set_bare method" do
	  obj = Regress::TestObj.new_from_file("bar")
	  @o.set_bare obj
	  # TODO: What is the correct value to retrieve from the fields?
	  assert_equal obj.to_ptr, @o[:bare]
	end

	should "have a working #instance_method method" do
	  rv = @o.instance_method
	  assert_equal(-1, rv)
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

	should "have a working #instance_method_callback method" do
	  a = 1
	  @o.instance_method_callback Proc.new { a = 2 }
	  assert_equal 2, a
	end

	should "not respond to #static_method" do
	  assert_raises(NoMethodError) { @o.static_method 1 }
	end
        # TODO: Test instance's fields and properies.
      end

      describe "its 'test' signal" do
        it "properly passes its arguments" do
          a = b = nil
          o = Regress::TestSubObj.new
          GObject.signal_connect(o, "test", 2) { |i, d| a = d; b = i }
          GObject.signal_emit o, "test"
          # TODO: store o's identity somewhere so we can make o == b.
          assert_equal [2, o.to_ptr], [a, b.to_ptr]
        end
      end

      # TODO: Test other signals.
    end

    context "the Regress::TestSimpleBoxedA class" do
      should "create an instance using #new" do
	obj = Regress::TestSimpleBoxedA.new
	assert_instance_of Regress::TestSimpleBoxedA, obj
      end

      context "an instance" do
	setup do
	  @obj = Regress::TestSimpleBoxedA.new
	  @obj[:some_int] = 4236
	  @obj[:some_int8] = 36
	  @obj[:some_double] = 23.53
	  @obj[:some_enum] = :value2
	end

	context "its equals method" do
	  setup do
	    @ob2 = Regress::TestSimpleBoxedA.new
	    @ob2[:some_int] = 4236
	    @ob2[:some_int8] = 36
	    @ob2[:some_double] = 23.53
	    @ob2[:some_enum] = :value2
	  end

	  should "return true if values are the same" do
	    assert_equal true, @obj.equals(@ob2)
	  end

	  should "return true if enum values differ" do
	    @ob2[:some_enum] = :value3
	    assert_equal true, @obj.equals(@ob2)
	  end

	  should "return false if other values differ" do
	    @ob2[:some_int] = 1
	    assert_equal false, @obj.equals(@ob2)
	  end
	end

	context "its copy method" do
	  setup do
	    @ob2 = @obj.copy
	  end

	  should "return an instance of TestSimpleBoxedA" do
	    assert_instance_of Regress::TestSimpleBoxedA, @ob2
	  end

	  should "copy fields" do
	    assert_equal 4236, @ob2[:some_int]
	    assert_equal 36, @ob2[:some_int8]
	    assert_equal 23.53, @ob2[:some_double]
	    assert_equal :value2, @ob2[:some_enum]
	  end

	  should "create a true copy" do
	    @obj[:some_int8] = 89
	    assert_equal 36, @ob2[:some_int8]
	  end
	end
      end
    end

    context "the Regress::TestStructA class" do
      context "an instance" do
	should "have a working clone method" do
	  a = Regress::TestStructA.new
	  a[:some_int] = 2556
	  a[:some_int8] = -10
	  a[:some_double] = 1.03455e20
	  a[:some_enum] = :value2

	  b = a.clone

	  assert_equal 2556, b[:some_int]
	  assert_equal(-10, b[:some_int8])
	  assert_equal 1.03455e20, b[:some_double]
	  assert_equal :value2, b[:some_enum]
	end
      end
    end

    describe "TestStructB" do
      describe "an instance" do
	it "has a working method #clone" do
	  a = Regress::TestStructB.new
	  a[:some_int8] = 42
	  a[:nested_a][:some_int] = 2556
	  a[:nested_a][:some_int8] = -10
	  a[:nested_a][:some_double] = 1.03455e20
	  a[:nested_a][:some_enum] = :value2

	  b = a.clone

	  assert_equal 42, b[:some_int8]
	  assert_equal 2556, b[:nested_a][:some_int]
	  assert_equal(-10, b[:nested_a][:some_int8])
	  assert_equal 1.03455e20, b[:nested_a][:some_double]
	  assert_equal :value2, b[:nested_a][:some_enum]
	end
      end
    end

    describe "TestStructC" do
      it "needs to be tested"
    end

    describe "TestSubObj" do
      it "is created with #new" do
        tso = Regress::TestSubObj.new
        assert_instance_of Regress::TestSubObj, tso
      end

      describe "an instance" do
        before do
          @tso = Regress::TestSubObj.new
        end

        it "has a working method #instance_method" do
          res = @tso.instance_method
          assert_equal 0, res
        end

        it "has a working method #unset_bare" do
          @tso.unset_bare
          pass
        end

        it "has a field parent_instance" do
          assert_instance_of Regress::TestObj::Struct, @tso[:parent_instance]
        end
      end
    end

    context "the Regress::TestWi8021x class" do
      should "create an instance using #new" do
	o = Regress::TestWi8021x.new
	assert_instance_of Regress::TestWi8021x, o
      end

      should "have a working #static_method" do
	assert_equal(-84, Regress::TestWi8021x.static_method(-42))
      end

      context "an instance" do
	setup do
	  @obj = Regress::TestWi8021x.new
	end

	should "set its boolean struct member with #set_testbool" do
	  @obj.set_testbool true
	  assert_equal 1, @obj[:testbool]
	  @obj.set_testbool false
	  assert_equal 0, @obj[:testbool]
	end

	should "get its boolean struct member with #get_testbool" do
	  @obj[:testbool] = 0
	  assert_equal false, @obj.get_testbool
	  @obj[:testbool] = 1
	  assert_equal true, @obj.get_testbool
	end

	should "get its boolean struct member with #get_property" do
	  @obj[:testbool] = 1
	  val = @obj.get_property "testbool"
	  assert_equal true, val
	end
      end
    end

    it "has the constant UTF8_CONSTANT" do
      assert_equal "const ♥ utf8", Regress::UTF8_CONSTANT
    end

    it "has the function #set_abort_on_error" do
      Regress.set_abort_on_error false
      Regress.set_abort_on_error true
    end

    describe "#test_array_fixed_size_int_in" do
      should "return the correct result" do
	assert_equal 5 + 4 + 3 + 2 + 1, Regress.test_array_fixed_size_int_in([5, 4, 3, 2, 1])
      end

      should "raise an error when called with the wrong number of arguments" do
	assert_raises ArgumentError do
	  Regress.test_array_fixed_size_int_in [2]
	end
      end
    end

    should "have correct test_array_fixed_size_int_out" do
      assert_equal [0, 1, 2, 3, 4], Regress.test_array_fixed_size_int_out
    end

    should "have correct test_array_fixed_size_int_return" do
      assert_equal [0, 1, 2, 3, 4], Regress.test_array_fixed_size_int_return
    end

    should "have correct test_array_gint16_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_gint16_in([5, 4, 3])
    end

    should "have correct test_array_gint32_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_gint32_in([5, 4, 3])
    end

    should "have correct test_array_gint64_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_gint64_in([5, 4, 3])
    end

    should "have correct test_array_gint8_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_gint8_in([5, 4, 3])
    end

    should "have correct test_array_gtype_in" do
      t1 = GObject.type_from_name "gboolean"
      t2 = GObject.type_from_name "gint64"
      assert_equal "[gboolean,gint64,]", Regress.test_array_gtype_in([t1, t2])
    end

    should "have correct test_array_int_full_out" do
      assert_equal [0, 1, 2, 3, 4], Regress.test_array_int_full_out
    end

    should "have correct test_array_int_in" do
      assert_equal 5 + 4 + 3, Regress.test_array_int_in([5, 4, 3])
    end

    should "have correct test_array_int_inout" do
      assert_equal [3, 4], Regress.test_array_int_inout([5, 2, 3])
    end

    should "have correct test_array_int_none_out" do
      assert_equal [1, 2, 3, 4, 5], Regress.test_array_int_none_out
    end

    should "have correct test_array_int_null_in" do
      assert_nothing_raised { Regress.test_array_int_null_in nil }
    end

    should "have correct test_array_int_null_out" do
      assert_equal nil, Regress.test_array_int_null_out
    end

    should "have correct test_array_int_out" do
      assert_equal [0, 1, 2, 3, 4], Regress.test_array_int_out
    end

    should "have correct test_async_ready_callback" do
      a = 1
      main_loop = GLib::MainLoop.new nil, false

      Regress.test_async_ready_callback Proc.new {
	main_loop.quit
	a = 2
      }

      main_loop.run

      assert_equal 2, a
    end

    should "have correct test_boolean" do
      assert_equal false, Regress.test_boolean(false)
      assert_equal true, Regress.test_boolean(true)
    end

    should "have correct test_boolean_false" do
      assert_equal false, Regress.test_boolean_false(false)
    end

    should "have correct test_boolean_true" do
      assert_equal true, Regress.test_boolean_true(true)
    end

    it "has correct #test_cairo_context_full_return" do
      ct = Regress.test_cairo_context_full_return
      assert_instance_of Cairo::Context, ct
    end

    it "has correct #test_cairo_context_none_in" do
      ct = Regress.test_cairo_context_full_return
      Regress.test_cairo_context_none_in ct
    end

    it "has correct #test_cairo_surface_full_out" do
      cs = Regress.test_cairo_surface_full_out
      assert_instance_of Cairo::Surface, cs
    end

    it "has correct #test_cairo_surface_full_return" do
      cs = Regress.test_cairo_surface_full_return
      assert_instance_of Cairo::Surface, cs
    end

    it "has correct #test_cairo_surface_none_in" do
      cs = Regress.test_cairo_surface_full_return
      Regress.test_cairo_surface_none_in cs
    end

    it "has correct #test_cairo_surface_none_return" do
      cs = Regress.test_cairo_surface_none_return
      assert_instance_of Cairo::Surface, cs
    end

    should "have correct test_callback" do
      result = Regress.test_callback Proc.new { 5 }
      assert_equal 5, result
    end

    should "have correct test_callback_async" do
      a = 1
      Regress.test_callback_async Proc.new {|b|
	a = 2
	b
      }, 44
      r = Regress.test_callback_thaw_async
      assert_equal 44, r
      assert_equal 2, a
    end

    should "have correct test_callback_destroy_notify" do
      a = 1
      r1 = Regress.test_callback_destroy_notify Proc.new {|b|
	a = 2
	b
      }, 42, Proc.new { a = 3 }
      assert_equal 2, a
      assert_equal 42, r1
      r2 = Regress.test_callback_thaw_notifications
      assert_equal 3, a
      assert_equal 42, r2
    end

    describe "the #test_callback_user_data function" do
      should "return the callbacks return value" do
	result = Regress.test_callback_user_data Proc.new {|u| 5 }, nil
	assert_equal 5, result
      end

      should "handle boolean user_data" do
	a = false
	Regress.test_callback_user_data Proc.new {|u|
	  a = u
	  5
	}, true
	assert_equal true, a
      end
    end

    should "have correct test_closure" do
      c = GObject::RubyClosure.new { 5235 }
      r = Regress.test_closure c
      assert_equal 5235, r
    end

    should "have correct test_closure_one_arg" do
      c = GObject::RubyClosure.new { |a| a * 2 }
      r = Regress.test_closure_one_arg c, 2
      assert_equal 4, r
    end

    it "has a correct #test_date_in_gvalue function" do
      r = Regress.test_date_in_gvalue
      date = r.ruby_value
      assert_equal [1984, :december, 5],
        [date.get_year, date.get_month, date.get_day]
    end

    should "have correct test_double" do
      r = Regress.test_double 5435.32
      assert_equal 5435.32, r
    end

    should "have correct test_enum_param" do
      r = Regress.test_enum_param :value3
      assert_equal "value3", r
    end

    # TODO: Find a way to test encoding issues.
    it "has correct #test_filename_return" do
      arr = Regress.test_filename_return
      assert_equal ["åäö", "/etc/fstab"], arr.to_a
    end

    should "have correct test_float" do
      r = Regress.test_float 5435.32
      assert_in_delta 5435.32, r, 0.001
    end

    describe "#test_garray_container_return" do
      before do
        @arr = Regress.test_garray_container_return
      end

      it "returns an instance of GLib::PtrArray" do
        @arr.must_be_instance_of GLib::PtrArray
      end

      it "returns the correct values" do
        @arr[:len].must_be :==, 1
        ptr = @arr[:pdata]
        ptr2 = ptr.read_pointer
        ptr2.read_string.must_be :==, "regress"
      end
    end

    describe "#test_ghash_container_return" do
      before do
        @hash = Regress.test_ghash_container_return
      end
      
      it "returns an instance of GLib::HashTable" do
        @hash.must_be_instance_of GLib::HashTable
      end

      it "returns the correct values" do
        @hash.to_hash.must_be :==, {"foo" => "bar", "baz" => "bat",
          "qux" => "quux"}
      end
    end

    it "has correct #test_ghash_everything_return" do
      ghash = Regress.test_ghash_everything_return
      ghash.to_hash.must_be :==, {"foo" => "bar", "baz" => "bat",
          "qux" => "quux"}
    end

    should "have correct test_ghash_nested_everything_return"
    should "have correct test_ghash_nested_everything_return2"

    it "has correct #test_ghash_nothing_in" do
      Regress.test_ghash_nothing_in({"foo" => "bar", "baz" => "bat",
          "qux" => "quux"})
    end

    it "has correct #test_ghash_nothing_in2" do
      Regress.test_ghash_nothing_in2({"foo" => "bar", "baz" => "bat",
          "qux" => "quux"})
    end

    it "has correct #test_ghash_nothing_return" do
      ghash = Regress.test_ghash_nothing_return
      ghash.to_hash.must_be :==, {"foo" => "bar", "baz" => "bat",
          "qux" => "quux"}
    end

    it "has correct #test_ghash_nothing_return2" do
      ghash = Regress.test_ghash_nothing_return2
      ghash.to_hash.must_be :==, {"foo" => "bar", "baz" => "bat",
          "qux" => "quux"}
    end

    it "has correct #test_ghash_null_in" do
      Regress.test_ghash_null_in(nil)
    end

    it "has correct #test_ghash_null_out" do
      ghash = Regress.test_ghash_null_out
      ghash.must_be_nil
    end

    it "has correct #test_ghash_null_return" do
      ghash = Regress.test_ghash_null_return
      ghash.must_be_nil
    end

    context "#test_glist_container_return" do
      setup do
        @list = Regress.test_glist_container_return
      end

      should "return an instance of GLib::SList" do
        assert_instance_of GLib::List, @list
      end

      should "return the correct values" do
        assert_equal ["1", "2", "3"], @list.to_a
      end
    end

    should "have correct test_glist_everything_return" do
      list = Regress.test_glist_everything_return
      assert_equal ["1", "2", "3"], list.to_a
    end

    should "have correct test_glist_nothing_in" do
      assert_nothing_raised {
        Regress.test_glist_nothing_in ["1", "2", "3"]
      }
    end

    should "have correct test_glist_nothing_in2" do
      assert_nothing_raised {
        Regress.test_glist_nothing_in2 ["1", "2", "3"]
      }
    end

    should "have correct test_glist_nothing_return" do
      list = Regress.test_glist_nothing_return
      assert_equal ["1", "2", "3"], list.to_a
    end

    should "have correct test_glist_nothing_return2" do
      list = Regress.test_glist_nothing_return2
      assert_equal ["1", "2", "3"], list.to_a
    end

    should "have correct test_glist_null_in" do
      assert_nothing_raised {
        Regress.test_glist_null_in nil
      }
    end

    should "have correct test_glist_null_out" do
      result = Regress.test_glist_null_out
      assert_equal nil, result
    end

    context "#test_gslist_container_return" do
      setup do
        @slist = Regress.test_gslist_container_return
      end

      should "return a GLib::SList object" do
        assert_instance_of GLib::SList, @slist
      end

      should "return the correct values" do
        assert_equal ["1", "2", "3"], @slist.to_a
      end
    end

    should "have correct test_gslist_everything_return" do
      slist = Regress.test_gslist_everything_return
      assert_equal ["1", "2", "3"], slist.to_a
    end

    should "have correct test_gslist_nothing_in" do
      assert_nothing_raised {
        Regress.test_gslist_nothing_in ["1", "2", "3"]
      }
    end

    should "have correct test_gslist_nothing_in2" do
      assert_nothing_raised {
        Regress.test_gslist_nothing_in2 ["1", "2", "3"]
      }
    end

    should "have correct test_gslist_nothing_return" do
      slist = Regress.test_gslist_nothing_return
      assert_equal ["1", "2", "3"], slist.to_a
    end

    should "have correct test_gslist_nothing_return2" do
      slist = Regress.test_gslist_nothing_return2
      assert_equal ["1", "2", "3"], slist.to_a
    end

    should "have correct test_gslist_null_in" do
      assert_nothing_raised {
        Regress.test_gslist_null_in nil
      }
    end

    context "#test_gslist_null_out" do
      should "return nil" do
        result = Regress.test_gslist_null_out
        assert_equal nil, result
      end
    end

    should "have correct test_gtype" do
      result = Regress.test_gtype 23
      assert_equal 23, result
    end

    should "have correct test_int" do
      result = Regress.test_int 23
      assert_equal 23, result
    end

    should "have correct test_int16" do
      result = Regress.test_int16 23
      assert_equal 23, result
    end

    should "have correct test_int32" do
      result = Regress.test_int32 23
      assert_equal 23, result
    end

    should "have correct test_int64" do
      result = Regress.test_int64 2300000000000
      assert_equal 2300000000000, result
    end

    should "have correct test_int8" do
      result = Regress.test_int8 23
      assert_equal 23, result
    end

    should "have correct test_int_out_utf8" do
      len = Regress.test_int_out_utf8 "How long?"
      assert_equal 9, len
    end

    should "have correct test_int_value_arg" do
      gv = GObject::Value.new
      gv.init GObject.type_from_name "gint"
      gv.set_int 343
      result = Regress.test_int_value_arg gv
      assert_equal 343, result
    end

    should "have correct test_long" do
      result = Regress.test_long 2300000000000
      assert_equal 2300000000000, result
    end

    should "have correct test_multi_callback" do
      a = 1
      result = Regress.test_multi_callback Proc.new {
	a += 1
	23
      }
      assert_equal 2 * 23, result
      assert_equal 3, a
    end

    should "have correct test_multi_double_args" do
      one, two = Regress.test_multi_double_args 23.1
      assert_equal 2 * 23.1, one
      assert_equal 3 * 23.1, two
    end

    should "have correct test_short" do
      result = Regress.test_short 23
      assert_equal 23, result
    end

    should "have correct test_simple_boxed_a_const_return" do
      result = Regress.test_simple_boxed_a_const_return
      assert_equal [5, 6, 7.0], [result[:some_int], result[:some_int8], result[:some_double]]
    end

    describe "the #test_simple_callback function" do
      should "call the passed-in proc" do
	a = 0
	Regress.test_simple_callback Proc.new { a = 1 }
	assert_equal 1, a
      end

      # XXX: The scope data does not seem to be reliable enough.
      if false
      should "not store the proc in CALLBACKS" do
	n = Regress::Lib::CALLBACKS.length
	Regress.test_simple_callback Proc.new { }
	assert_equal n, Regress::Lib::CALLBACKS.length
      end
      end
    end

    should "have correct test_size" do
      assert_equal 2354, Regress.test_size(2354)
    end

    should "have correct test_ssize" do
      assert_equal(-2_000_000, Regress.test_ssize(-2_000_000))
    end

    should "have correct test_strv_in" do
      assert_equal true, Regress.test_strv_in(['1', '2', '3'])
    end

    it "has correct #test_strv_in_gvalue" do
      gv = Regress.test_strv_in_gvalue
      assert_equal ['one', 'two', 'three'], gv.ruby_value
    end

    it "has correct #test_strv_out" do
      arr = Regress.test_strv_out
      assert_equal ["thanks", "for", "all", "the", "fish"], arr
    end

    it "has correct #test_strv_out_c" do
      arr = Regress.test_strv_out_c
      assert_equal ["thanks", "for", "all", "the", "fish"], arr
    end

    it "has correct #test_strv_out_container" do
      arr = Regress.test_strv_out_container
      assert_equal ['1', '2', '3'], arr
    end

    it "has correct #test_strv_outarg" do
      arr = Regress.test_strv_outarg
      assert_equal ['1', '2', '3'], arr
    end

    should "have correct test_timet" do
      # Time rounded to seconds.
      t = Time.at(Time.now.to_i)
      result = Regress.test_timet(t.to_i)
      assert_equal t, Time.at(result)
    end

    should "have correct test_torture_signature_0" do
      y, z, q = Regress.test_torture_signature_0 86, "foo", 2
      assert_equal [86, 2*86, 3+2], [y, z, q]
    end

    context "its #test_torture_signature_1 method" do
      should "work for m even" do
	ret, y, z, q = Regress.test_torture_signature_1(-21, "hello", 12)
	assert_equal [true, -21, 2 * -21, "hello".length + 12], [ret, y, z, q]
      end

      should "throw an exception for m odd" do
	assert_raises RuntimeError do
	  Regress.test_torture_signature_1(-21, "hello", 11)
	end
      end
    end
      
    should "have correct test_torture_signature_2" do
      a = 1
      y, z, q = Regress.test_torture_signature_2 244,
	Proc.new {|u| a = u }, 2, Proc.new { a = 3 },
	"foofoo", 31
      assert_equal [244, 2*244, 6+31], [y, z, q]
      assert_equal 3, a
    end

    should "have correct test_uint" do
      assert_equal 31, Regress.test_uint(31)
    end

    should "have correct test_uint16" do
      assert_equal 31, Regress.test_uint16(31)
    end

    should "have correct test_uint32" do
      assert_equal 540000, Regress.test_uint32(540000)
    end

    should "have correct test_uint64" do
      assert_equal 54_000_000_000_000, Regress.test_uint64(54_000_000_000_000)
    end

    should "have correct test_uint8" do
      assert_equal 31, Regress.test_uint8(31)
    end

    should "have correct test_ulong" do
      assert_equal 54_000_000_000_000, Regress.test_uint64(54_000_000_000_000)
    end

    it "has a correct #test_unichar" do
      assert_equal 120, Regress.test_unichar(120)
      assert_equal 540_000, Regress.test_unichar(540_000)
    end

    it "has a correct #test_unsigned_enum_param" do
      assert_equal "value1", Regress.test_unsigned_enum_param(:value1)
      assert_equal "value2", Regress.test_unsigned_enum_param(:value2)
    end

    should "have correct test_ushort" do
      assert_equal 54_000_000, Regress.test_uint64(54_000_000)
    end

    should "have correct test_utf8_const_in" do
      assert_nothing_raised do
	Regress.test_utf8_const_in("const \xe2\x99\xa5 utf8")
      end
    end

    should "have correct test_utf8_const_return" do
      result = Regress.test_utf8_const_return
      assert_equal "const \xe2\x99\xa5 utf8", result
    end

    should "have correct test_utf8_inout" do
      result = Regress.test_utf8_inout "const \xe2\x99\xa5 utf8"
      assert_equal "nonconst \xe2\x99\xa5 utf8", result
    end

    should "have correct test_utf8_nonconst_return" do
      result = Regress.test_utf8_nonconst_return
      assert_equal "nonconst \xe2\x99\xa5 utf8", result
    end

    should "have correct test_utf8_null_in" do
      assert_nothing_raised do
	Regress.test_utf8_null_in nil
      end
    end

    should "have correct test_utf8_null_out" do
      assert_equal nil, Regress.test_utf8_null_out
    end

    should "have correct test_utf8_out" do
      result = Regress.test_utf8_out
      assert_equal "nonconst \xe2\x99\xa5 utf8", result
    end

    should "have correct test_utf8_out_nonconst_return" do
      r, out = Regress.test_utf8_out_nonconst_return
      assert_equal ["first", "second"], [r, out]
    end

    should "have correct test_utf8_out_out" do
      out0, out1 = Regress.test_utf8_out_nonconst_return
      assert_equal ["first", "second"], [out0, out1]
    end

    should "have correct test_value_return" do
      result = Regress.test_value_return 3423
      assert_equal 3423, result.get_int
    end

    it "raises an appropriate NoMethodError when a function is not found" do
      begin
        Regress.this_method_does_not_exist
      rescue => e
        assert_equal "undefined method `this_method_does_not_exist' for Regress:Module", e.message
      end
    end
  end

end
