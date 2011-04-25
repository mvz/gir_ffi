require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Tests generated methods and functions in the GIMarshallingTests namespace.
describe "GIMarshallingTests" do
  before do
    GirFFI.setup :GIMarshallingTests
  end

  describe "BoxedStruct" do
    it "is created with #new" do
      bx = GIMarshallingTests::BoxedStruct.new
      assert_instance_of GIMarshallingTests::BoxedStruct, bx
    end

    describe "an instance" do
      before do
        @bx = GIMarshallingTests::BoxedStruct.new
        @bx[:long_] = 42
      end

      it "has a working method #inv" do
        @bx.inv
        pass
      end

      it "has a field :long_" do
        assert_equal 42, @bx[:long_]
      end

      # TODO: More friendly access to array fields.
      it "has a field :g_strv" do
        assert @bx[:g_strv].null?
      end
    end
  end

  it "has the constant CONSTANT_GERROR_CODE" do
    assert_equal 5, GIMarshallingTests::CONSTANT_GERROR_CODE
  end

  it "has the constant CONSTANT_GERROR_DOMAIN" do
    assert_equal "gi-marshalling-tests-gerror-domain",
      GIMarshallingTests::CONSTANT_GERROR_DOMAIN
  end

  it "has the constant CONSTANT_GERROR_MESSAGE" do
    assert_equal "gi-marshalling-tests-gerror-message",
      GIMarshallingTests::CONSTANT_GERROR_MESSAGE
  end

  it "has the constant CONSTANT_NUMBER" do
    assert_equal 42, GIMarshallingTests::CONSTANT_NUMBER
  end

  it "has the constant CONSTANT_UTF8" do
    assert_equal "const ♥ utf8", GIMarshallingTests::CONSTANT_UTF8
  end

  it "has the enum Enum" do
    assert_equal 0, GIMarshallingTests::Enum[:value1]
    assert_equal 1, GIMarshallingTests::Enum[:value2]
    assert_equal 42, GIMarshallingTests::Enum[:value3]
  end

  it "has the bitfield Flags" do
    assert_equal 1, GIMarshallingTests::Flags[:value1]
    assert_equal 2, GIMarshallingTests::Flags[:value2]
    assert_equal 4, GIMarshallingTests::Flags[:value3]
    assert_equal 3, GIMarshallingTests::Flags[:mask]
    assert_equal 3, GIMarshallingTests::Flags[:mask2]
  end

  it "has the enum GEnum" do
    assert_equal 0, GIMarshallingTests::GEnum[:value1]
    assert_equal 1, GIMarshallingTests::GEnum[:value2]
    assert_equal 42, GIMarshallingTests::GEnum[:value3]
  end

  describe "Interface" do
    it "must be tested"
  end

  describe "Interface2" do
    it "must be tested"
  end

  describe "NestedStruct" do
    it "contains a SimpleStruct" do
      ns = GIMarshallingTests::NestedStruct.new
      # FIXME: Make it an instance of SimpleStruct
      assert_instance_of GIMarshallingTests::SimpleStruct::Struct,
        ns[:simple_struct]
    end
  end

  it "has the bitfield NoTypeFlags" do
    assert_equal 1, GIMarshallingTests::NoTypeFlags[:value1]
    assert_equal 2, GIMarshallingTests::NoTypeFlags[:value2]
    assert_equal 4, GIMarshallingTests::NoTypeFlags[:value3]
    assert_equal 3, GIMarshallingTests::NoTypeFlags[:mask]
    assert_equal 3, GIMarshallingTests::NoTypeFlags[:mask2]
  end

  describe "NotSimpleStruct" do
    it "must be tested"
  end

  it "has the constant OVERRIDES_CONSTANT" do
    assert_equal 42, GIMarshallingTests::OVERRIDES_CONSTANT
  end

  describe "Object" do
    it "creates instances with #new" do
      ob = GIMarshallingTests::Object.new 42
      assert_instance_of GIMarshallingTests::Object, ob
      assert_equal 42, ob[:int_]
    end

    it "has a working function #full_inout" do
      ob = GIMarshallingTests::Object.new 42
      res = GIMarshallingTests::Object.full_inout ob
      assert_instance_of GIMarshallingTests::Object, res
      refute_equal res.to_ptr, ob.to_ptr
    end

    it "has a working function #full_out" do
      res = GIMarshallingTests::Object.full_out
      assert_instance_of GIMarshallingTests::Object, res
    end

    it "has a working function #full_return" do
      res = GIMarshallingTests::Object.full_return
      assert_instance_of GIMarshallingTests::Object, res
    end

    it "has a working function #inout_same" do
      skip "This function is only found in the header"
    end

    it "has a working function #none_inout" do
      ob = GIMarshallingTests::Object.new 42
      res = GIMarshallingTests::Object.none_inout ob
      assert_instance_of GIMarshallingTests::Object, res
      refute_equal res.to_ptr, ob.to_ptr
    end

    it "has a working function #none_out" do
      res = GIMarshallingTests::Object.none_out
      assert_instance_of GIMarshallingTests::Object, res
    end

    it "has a working function #none_return" do
      res = GIMarshallingTests::Object.none_return
      assert_instance_of GIMarshallingTests::Object, res
    end

    it "has a working function #static_method" do
      GIMarshallingTests::Object.static_method
      pass
    end

    it "has a working function #static_method" do
      GIMarshallingTests::Object.static_method
      pass
    end

    describe "an instance" do
      before do
        @obj = GIMarshallingTests::Object.new 42
      end

      it "has a working virtual method #method_int8_in"
      it "has a working virtual method #method_int8_out"

      it "has a working virtual method #method_with_default_implementation" do
        @obj.method_with_default_implementation 104
        assert_equal 104, @obj[:int_]
      end

      it "has a working method #full_in" do
        skip "This function is only found in the header"
      end

      it "has a working method #int8_in"
      it "has a working method #int8_out"

      # TODO: Avoid using common method names?
      it "has a working method #method" do
        @obj.method
        pass
      end

      it "has a working method #method_array_in" do
        @obj.method_array_in [-1, 0, 1, 2]
        pass
      end

      it "has a working method #method_array_inout" do
        res = @obj.method_array_inout [-1, 0, 1, 2]
        assert_equal [-2, -1, 0, 1, 2], res
      end

      it "has a working method #method_array_out" do
        res = @obj.method_array_out
        assert_equal [-1, 0, 1, 2], res
      end

      it "has a working method #method_array_return" do
        res = @obj.method_array_return
        assert_equal [-1, 0, 1, 2], res
      end

      it "has a working method #none_in" do
        @obj.none_in
        pass
      end

      it "has a working method #overridden_method" do
        @obj[:int_] = 0
        @obj.overridden_method
        pass
      end

      it "has a property 'int'"

      it "has a field parent_instance containing the parent struct" do
        skip "This fails sometimes, perhaps due to a race condition"
        assert_instance_of GObject::Object::Struct, @obj[:parent_instance]
      end

      it "has a field int_ containing the argument to #new" do
        assert_equal 42, @obj[:int_]
      end
    end
  end

  describe "OverridesObject" do
    it "creates instances with #new" do
      ob = GIMarshallingTests::OverridesObject.new
      assert_instance_of GIMarshallingTests::OverridesObject, ob
    end

    it "creates instances with #returnv" do
      ob = GIMarshallingTests::OverridesObject.returnv
      assert_instance_of GIMarshallingTests::OverridesObject, ob
    end

    describe "an instance" do
      before do
        @obj = GIMarshallingTests::OverridesObject.new
      end

      it "has a field parent_instance containing the parent struct" do
        skip "This fails, perhaps due to a race condition"
        assert_instance_of GObject::Object::Struct, @obj[:parent_instance]
      end

      it "has a field long_" do
        assert_equal 0.0, @obj[:long_]
      end
    end
  end

  describe "PointerStruct" do
    it "creates instances with #new" do
      ps = GIMarshallingTests::PointerStruct.new
      assert_instance_of GIMarshallingTests::PointerStruct, ps
    end

    describe "an instance" do
      before do
        @ps = GIMarshallingTests::PointerStruct.new
      end

      it "has a field long_" do
        assert_equal 0.0, @ps[:long_]
      end

      it "has a working method #inv" do
        @ps[:long_] = 42.0
        @ps.inv
        pass
      end
    end
  end

  it "has the enum SecondEnum" do
    assert_equal 0, GIMarshallingTests::SecondEnum[:secondvalue1]
    assert_equal 1, GIMarshallingTests::SecondEnum[:secondvalue2]
  end

  describe "SimpleStruct" do
    it "creates instances with #new" do
      ss = GIMarshallingTests::SimpleStruct.new
      assert_instance_of GIMarshallingTests::SimpleStruct, ss
    end

    describe "an instance" do
      before do
        @ss = GIMarshallingTests::SimpleStruct.new
      end

      it "has a field long_" do
        assert_equal 0, @ss[:long_]
      end

      it "has a field int8" do
        assert_equal 0, @ss[:int8]
      end

      it "has a working method #inv" do
        @ss[:long_] = 6
        @ss[:int8] = 7
        @ss.inv
        pass
      end
    end
  end

  describe "SubObject" do
    it "creates instances with #new" do
      so = GIMarshallingTests::SubObject.new 42
      assert_instance_of GIMarshallingTests::SubObject, so
    end

    describe "an instance" do
      before do
        @so = GIMarshallingTests::SubObject.new 0
      end

      it "has the method #overwritten_method" do
        @so.overwritten_method
        pass
      end

      it "has the method #sub_method" do
        @so.sub_method
        pass
      end

      it "has a field parent_instance containing the parent struct" do
        assert_instance_of GIMarshallingTests::Object::Struct, @so[:parent_instance]
      end

      it "has a working inherited virtual method #method_int8_in"
      it "has a working inherited virtual method #method_int8_out"

      it "has a working inherited virtual method #method_with_default_implementation" do
        @so.method_with_default_implementation 104
        assert_equal 104, @so[:parent_instance][:int_]
      end

      it "has a working inherited method #int8_in"
      it "has a working inherited method #int8_out"

      it "has a working inherited method #method" do
        @so[:parent_instance][:int_] = 42
        @so.method
        pass
      end

      it "has a working inherited method #method_array_in" do
        @so.method_array_in [-1, 0, 1, 2]
        pass
      end

      it "has a working inherited method #method_array_inout" do
        res = @so.method_array_inout [-1, 0, 1, 2]
        assert_equal [-2, -1, 0, 1, 2], res
      end

      it "has a working inherited method #method_array_out" do
        res = @so.method_array_out
        assert_equal [-1, 0, 1, 2], res
      end

      it "has a working inherited method #method_array_return" do
        res = @so.method_array_return
        assert_equal [-1, 0, 1, 2], res
      end

      it "has a working inherited method #none_in" do
        @so[:parent_instance][:int_] = 42
        @so.none_in
        pass
      end

      it "has a working inherited method #overridden_method" do
        @so[:parent_instance][:int_] = 0
        @so.overridden_method
        pass
      end
    end
  end

  describe "Union" do
    it "creates an instance with #new" do
      u = GIMarshallingTests::Union.new
      assert_instance_of GIMarshallingTests::Union, u
    end

    describe "an instance" do
      before do
        @it = GIMarshallingTests::Union.new
      end

      it "has a field long_" do
        assert_equal 0, @it[:long_]
      end

      it "has a working method #inv" do
        @it[:long_] = 42
        @it.inv
        pass
      end

      it "has a working method #method" do
        @it[:long_] = 42
        @it.method
        pass
      end
    end
  end

  it "has a working function #array_fixed_inout" do
    res = GIMarshallingTests.array_fixed_inout [-1, 0, 1, 2]
    assert_equal [2, 1, 0, -1], res
  end

  it "has a working function #array_fixed_int_in" do
    GIMarshallingTests.array_fixed_int_in [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_fixed_int_return" do
    res = GIMarshallingTests.array_fixed_int_return
    assert_equal [-1, 0, 1, 2], res
  end

  it "has a working function #array_fixed_out" do
    res = GIMarshallingTests.array_fixed_out
    assert_equal [-1, 0, 1, 2], res
  end

  it "has a working function #array_fixed_out_struct" do
    res = GIMarshallingTests.array_fixed_out_struct
    assert_equal [[7, 6], [6, 7]], res.map {|s| [s[:long_], s[:int8]]}
  end

  it "has a working function #array_fixed_short_in" do
    GIMarshallingTests.array_fixed_short_in [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_fixed_short_return" do
    res = GIMarshallingTests.array_fixed_short_return
    assert_equal [-1, 0, 1, 2], res
  end

  it "has a working function #array_gvariant_in" do
    v1 = GLib::Variant.new_int32(27)
    v2 = GLib::Variant.new_string("Hello")
    res = GIMarshallingTests.array_gvariant_in [v1, v2]
    pass
    # TODO: Can we determine that res should be an array?
    # assert_equal 27, res[0].get_int32
    # assert_equal "Hello", res[1].get_string
  end

  it "has a working function #array_in" do
    GIMarshallingTests.array_in [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_inout" do
    res = GIMarshallingTests.array_inout [-1, 0, 1, 2]
    assert_equal [-2, -1, 0, 1, 2], res
  end

  it "has a working function #array_out" do
    res = GIMarshallingTests.array_out
    assert_equal  [-1, 0, 1, 2], res
  end

  it "has a working function #array_return" do
    res = GIMarshallingTests.array_return
    assert_equal  [-1, 0, 1, 2], res
  end

  it "has a working function #array_uint8_in" do
    GIMarshallingTests.array_uint8_in [?a, ?b, ?c, ?d]
    pass
  end

  it "has a working function #array_zero_terminated_in" do
    GIMarshallingTests.array_zero_terminated_in ["0", "1", "2"]
    pass
  end

  it "has a working function #array_zero_terminated_out" do
    res = GIMarshallingTests.array_zero_terminated_out
    assert_equal ["0", "1", "2"], res
  end

  it "has a working function #array_zero_terminated_return" do
    res = GIMarshallingTests.array_zero_terminated_return
    assert_equal ["0", "1", "2"], res
  end

  it "has a working function #boolean_in_false" do
    GIMarshallingTests.boolean_in_false false
    pass
  end

  it "has a working function #boolean_in_true" do
    GIMarshallingTests.boolean_in_true true
    pass
  end

  it "has a working function #boolean_inout_false_true" do
    res = GIMarshallingTests.boolean_inout_false_true false
    assert_equal true, res
  end

  it "has a working function #boolean_inout_true_false" do
    res = GIMarshallingTests.boolean_inout_true_false true
    assert_equal false, res
  end

  it "has a working function #boolean_out_false" do
    res = GIMarshallingTests.boolean_out_false
    assert_equal false, res
  end

  it "has a working function #boolean_out_true" do
    res = GIMarshallingTests.boolean_out_true
    assert_equal true, res
  end

  it "has a working function #boolean_return_false" do
    res = GIMarshallingTests.boolean_return_false
    assert_equal false, res
  end

  it "has a working function #boolean_return_true" do
    res = GIMarshallingTests.boolean_return_true
    assert_equal true, res
  end
end

