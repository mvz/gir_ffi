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

    # This function is only found in the header
    # it "has a working function #inout_same"

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

      # This function is only found in the header
      # it "has a working method #full_in"

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

  it "has a working function #boxed_struct_inout" do
    bx = GIMarshallingTests::BoxedStruct.new
    bx[:long_] = 42
    res = GIMarshallingTests.boxed_struct_inout bx
    assert_equal 0, res[:long_]
  end

  it "has a working function #boxed_struct_out" do
    res = GIMarshallingTests.boxed_struct_out
    assert_equal 42, res[:long_]
  end

  it "has a working function #boxed_struct_returnv" do
    res = GIMarshallingTests.boxed_struct_returnv
    assert_equal 42, res[:long_]
    assert_equal ["0", "1", "2"], GirFFI::ArgHelper.strz_to_utf8_array(res[:g_strv])
  end

  it "has a working function #bytearray_full_return" do
    ret = GIMarshallingTests.bytearray_full_return
    assert_instance_of GLib::ByteArray, ret
    assert_equal "0123", ret.to_string
  end

  it "has a working function #bytearray_none_in" do
    ba = GLib.byte_array_new
    GLib.byte_array_append ba, "0123"
    GIMarshallingTests.bytearray_none_in ba
    pass
  end

  it "has a working function #double_in" do
    GIMarshallingTests.double_in Float::MAX
    pass
  end

  it "has a working function #double_inout" do
    ret = GIMarshallingTests.double_inout Float::MAX
    assert_equal Float::MIN, ret
  end

  it "has a working function #double_out" do
    ret = GIMarshallingTests.double_out
    assert_equal Float::MAX, ret
  end

  it "has a working function #double_return" do
    ret = GIMarshallingTests.double_return
    assert_equal Float::MAX, ret
  end

  it "has a working function #enum_in" do
    GIMarshallingTests.enum_in :value3
    pass
  end

  it "has a working function #enum_inout" do
    e = GIMarshallingTests.enum_inout :value3
    assert_equal :value1, e
  end

  it "has a working function #enum_out" do
    e = GIMarshallingTests.enum_out
    assert_equal :value3, e
  end

  it "has a working function #enum_returnv" do
    e = GIMarshallingTests.enum_returnv
    assert_equal :value3, e
  end

  it "has a working function #filename_list_return" do
    fl = GIMarshallingTests.filename_list_return
    assert_equal nil, fl
  end

  it "has a working function #flags_in" do
    GIMarshallingTests.flags_in :value2
    pass
  end

  it "has a working function #flags_in_zero" do
    GIMarshallingTests.flags_in_zero 0
    pass
  end

  it "has a working function #flags_inout" do
    res = GIMarshallingTests.flags_inout :value2
    assert_equal :value1, res
  end

  it "has a working function #flags_out" do
    res = GIMarshallingTests.flags_out
    assert_equal :value2, res
  end

  it "has a working function #flags_returnv" do
    res = GIMarshallingTests.flags_returnv
    assert_equal :value2, res
  end

  it "has a working function #float_in" do
    # float_return returns MAX_FLT
    flt = GIMarshallingTests.float_return
    GIMarshallingTests.float_in flt
    pass
  end

  it "has a working function #float_inout" do
    # float_return returns MAX_FLT
    flt = GIMarshallingTests.float_return
    res = GIMarshallingTests.float_inout flt
    assert_in_epsilon 1.175e-38, res
  end

  it "has a working function #float_out" do
    flt = GIMarshallingTests.float_out
    assert_in_epsilon 3.402e+38, flt
  end

  it "has a working function #float_return" do
    flt = GIMarshallingTests.float_return
    assert_in_epsilon 3.402e+38, flt
  end

  it "has a working function #garray_int_none_in" do
    arr = GLib.array_new :int
    GLib.array_append_vals arr, [-1, 0, 1, 2]
    GIMarshallingTests.garray_int_none_in arr
    pass
  end

  it "has a working function #garray_int_none_return" do
    arr = GIMarshallingTests.garray_int_none_return
    assert_equal [-1, 0, 1, 2], arr.to_a
  end

  it "has a working function #garray_utf8_container_out" do
    res = GIMarshallingTests.garray_utf8_container_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #garray_utf8_container_return" do
    res = GIMarshallingTests.garray_utf8_container_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  # TODO: Allow regular arrays as arguments directly.
  it "has a working function #garray_utf8_full_inout" do
    arr = GLib.array_new :utf8
    GLib.array_append_vals arr, ["0", "1", "2"]
    res = GIMarshallingTests.garray_utf8_full_inout arr
    assert_equal ["-2", "-1", "0", "1"], res.to_a
  end

  it "has a working function #garray_utf8_full_out" do
    res = GIMarshallingTests.garray_utf8_full_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #garray_utf8_full_return" do
    res = GIMarshallingTests.garray_utf8_full_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #garray_utf8_none_in" do
    arr = GLib.array_new :utf8
    GLib.array_append_vals arr, ["0", "1", "2"]
    GIMarshallingTests.garray_utf8_none_in arr
    pass
  end

  it "has a working function #garray_utf8_none_inout" do
    arr = GLib.array_new :utf8
    GLib.array_append_vals arr, ["0", "1", "2"]
    res = GIMarshallingTests.garray_utf8_none_inout arr
    assert_equal ["-2", "-1", "0", "1"], res.to_a
  end

  it "has a working function #garray_utf8_none_out" do
    res = GIMarshallingTests.garray_utf8_none_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #garray_utf8_none_return" do
    res = GIMarshallingTests.garray_utf8_none_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gclosure_in" do
    cl = GObject::RubyClosure.new { 42 }
    GIMarshallingTests.gclosure_in cl
  end

  it "has a working function #gclosure_return" do
    cl = GIMarshallingTests.gclosure_return
    gv = GObject::Value.wrap_ruby_value 0
    cl.invoke gv, nil, nil
    assert_equal 42, gv.ruby_value
  end

  it "has a working function #genum_in" do
    GIMarshallingTests.genum_in :value3
    pass
  end

  it "has a working function #genum_inout" do
    res = GIMarshallingTests.genum_inout :value3
    assert_equal :value1, res
  end

  it "has a working function #genum_out" do
    res = GIMarshallingTests.genum_out
    assert_equal :value3, res
  end

  it "has a working function #genum_returnv" do
    res = GIMarshallingTests.genum_returnv
    assert_equal :value3, res
  end

  it "has a working function #gerror" do
    begin
      GIMarshallingTests.gerror
    rescue RuntimeError => e
      assert_equal "gi-marshalling-tests-gerror-message", e.message
    end
  end

  it "has a working function #gerror_array_in" do
    begin
      GIMarshallingTests.gerror_array_in [1, 2, 3]
    rescue RuntimeError => e
      assert_equal "gi-marshalling-tests-gerror-message", e.message
    end
  end

  it "has a working function #ghashtable_int_none_in" do
    GIMarshallingTests.ghashtable_int_none_in(
      {-1 => 1, 0 => 0, 1 => -1, 2 => -2})
  end

  it "has a working function #ghashtable_int_none_return" do
    gh = GIMarshallingTests.ghashtable_int_none_return
    assert_equal({-1 => 1, 0 => 0, 1 => -1, 2 => -2}, gh.to_hash)
  end

  # XXX: Only defined in header
  # it "has a working function #ghashtable_utf8_container_in"

  it "has a working function #ghashtable_utf8_container_inout" do
    hsh = {"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"}
    res = GIMarshallingTests.ghashtable_utf8_container_inout hsh
    assert_equal({"-1" => "1", "0" => "0", "1" => "1"}, res.to_hash)
  end

  it "has a working function #ghashtable_utf8_container_out" do
    res = GIMarshallingTests.ghashtable_utf8_container_out
    assert_equal({"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"},
                 res.to_hash)
  end

  it "has a working function #ghashtable_utf8_container_return" do
    res = GIMarshallingTests.ghashtable_utf8_container_return
    assert_equal({"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"},
                 res.to_hash)
  end

  # XXX: Only defined in header
  # it "has a working function #ghashtable_utf8_full_in"

  it "has a working function #ghashtable_utf8_full_inout" do
    hsh = {"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"}
    res = GIMarshallingTests.ghashtable_utf8_full_inout hsh
    assert_equal({"-1" => "1", "0" => "0", "1" => "1"}, res.to_hash)
  end

  it "has a working function #ghashtable_utf8_full_out" do
    res = GIMarshallingTests.ghashtable_utf8_full_out
    assert_equal({"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"},
                 res.to_hash)
  end

  it "has a working function #ghashtable_utf8_full_return" do
    res = GIMarshallingTests.ghashtable_utf8_full_return
    assert_equal({"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"},
                 res.to_hash)
  end

  it "has a working function #ghashtable_utf8_none_in" do
    hsh = {"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"}
    GIMarshallingTests.ghashtable_utf8_none_in hsh
    pass
  end

  it "has a working function #ghashtable_utf8_none_inout" do
    hsh = {"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"}
    res = GIMarshallingTests.ghashtable_utf8_none_inout hsh
    assert_equal({"-1" => "1", "0" => "0", "1" => "1"}, res.to_hash)
  end

  it "has a working function #ghashtable_utf8_none_out" do
    res = GIMarshallingTests.ghashtable_utf8_none_out
    assert_equal({"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"},
                 res.to_hash)
  end

  it "has a working function #ghashtable_utf8_none_return" do
    res = GIMarshallingTests.ghashtable_utf8_none_return
    assert_equal({"-1" => "1", "0" => "0", "1" => "-1", "2" => "-2"},
                 res.to_hash)
  end

end

