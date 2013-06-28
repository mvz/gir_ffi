# coding: utf-8
require 'gir_ffi_test_helper'

require 'gir_ffi'

GirFFI.setup :GIMarshallingTests

# Tests generated methods and functions in the GIMarshallingTests namespace.
describe GIMarshallingTests do
  describe "GIMarshallingTests::BoxedStruct" do
    it "creates an instance using #new" do
      bx = GIMarshallingTests::BoxedStruct.new
      assert_instance_of GIMarshallingTests::BoxedStruct, bx
    end

    let(:instance) { GIMarshallingTests::BoxedStruct.new }

    it "has a working method #inv" do
      instance.long_ = 42
      instance.inv
      pass
    end

    describe "an instance" do
      before do
        @bx = instance
        @bx.long_ = 42
      end

      it "has a writable field long_" do
        assert_equal 42, @bx.long_
        @bx.long_ = 43
        assert_equal 43, @bx.long_
      end

      it "has a writable field g_strv" do
        assert_equal [], @bx.g_strv.to_a
        @bx.g_strv = ["foo", "bar"]
        assert_equal ["foo", "bar"], @bx.g_strv.to_a
      end
    end

    it "has a working function #inout" do
      bx = GIMarshallingTests::BoxedStruct.new
      bx.long_ = 42

      res = GIMarshallingTests::BoxedStruct.inout bx

      assert_equal 42, bx.long_
      assert_equal 0, res.long_
    end

    it "has a working function #out" do
      res = GIMarshallingTests::BoxedStruct.out
      assert_equal 42, res.long_
    end

    it "has a working function #returnv" do
      res = GIMarshallingTests::BoxedStruct.returnv
      assert_equal 42, res.long_
      assert_equal ["0", "1", "2"], res.g_strv.to_a
    end
  end

  it "has the constant CONSTANT_GERROR_CODE" do
    assert_equal 5, GIMarshallingTests::CONSTANT_GERROR_CODE
  end

  it "has the constant CONSTANT_GERROR_DEBUG_MESSAGE" do
    GIMarshallingTests::CONSTANT_GERROR_DEBUG_MESSAGE.must_equal(
      "we got an error, life is shit")
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

  describe "GIMarshallingTests::Enum" do
    it "has the member :value1" do
      assert_equal 0, GIMarshallingTests::Enum[:value1]
    end

    it "has the member :value2" do
      assert_equal 1, GIMarshallingTests::Enum[:value2]
    end

    it "has the member :value3" do
      assert_equal 42, GIMarshallingTests::Enum[:value3]
    end
  end

  describe "GIMarshallingTests::Flags" do
    it "has the member :value1" do
      assert_equal 1, GIMarshallingTests::Flags[:value1]
    end

    it "has the member :value2" do
      assert_equal 2, GIMarshallingTests::Flags[:value2]
    end

    it "has the member :value3" do
      assert_equal 4, GIMarshallingTests::Flags[:value3]
    end

    it "has the member :mask" do
      assert_equal 3, GIMarshallingTests::Flags[:mask]
    end

    it "has the member :mask2" do
      assert_equal 3, GIMarshallingTests::Flags[:mask2]
    end

    it "has a working function #in" do
      GIMarshallingTests::Flags.in :value2
    end

    it "has a working function #in_zero" do
      GIMarshallingTests::Flags.in_zero 0
    end

    it "has a working function #inout" do
      result = GIMarshallingTests::Flags.inout :value2
      result.must_equal :value1
    end

    it "has a working function #out" do
      result = GIMarshallingTests::Flags.out
      result.must_equal :value2
    end

    it "has a working function #returnv" do
      result = GIMarshallingTests::Flags.returnv
      result.must_equal :value2
    end
  end

  describe "GIMarshallingTests::GEnum" do
    it "has the member :value1" do
      assert_equal 0, GIMarshallingTests::GEnum[:value1]
    end

    it "has the member :value2" do
      assert_equal 1, GIMarshallingTests::GEnum[:value2]
    end

    it "has the member :value3" do
      assert_equal 42, GIMarshallingTests::GEnum[:value3]
    end

    it "has a working function #in" do
      GIMarshallingTests::GEnum.in :value3
    end

    it "has a working function #inout" do
      result = GIMarshallingTests::GEnum.inout :value3
      result.must_equal :value1
    end

    it "has a working function #out" do
      result = GIMarshallingTests::GEnum.out
      result.must_equal :value3
    end

    it "has a working function #returnv" do
      result = GIMarshallingTests::GEnum.returnv
      result.must_equal :value3
    end
  end

  describe "GIMarshallingTests::Interface" do
    it "has a working method #test_int8_in" do
      skip
    end
  end

  describe "GIMarshallingTests::Interface2" do
    it "must be tested" do
      skip
    end
  end

  describe "GIMarshallingTests::Interface3" do
    it "has a working method #test_variant_array_in" do
      skip
    end
  end

  describe "GIMarshallingTests::NestedStruct" do
    it "contains a SimpleStruct" do
      ns = GIMarshallingTests::NestedStruct.new
      assert_instance_of GIMarshallingTests::SimpleStruct,
        ns.simple_struct
    end
  end

  describe "GIMarshallingTests::NoTypeFlags" do
    it "has the member :value1" do
      assert_equal 1, GIMarshallingTests::NoTypeFlags[:value1]
    end
    it "has the member :value2" do
      assert_equal 2, GIMarshallingTests::NoTypeFlags[:value2]
    end
    it "has the member :value3" do
      assert_equal 4, GIMarshallingTests::NoTypeFlags[:value3]
    end
    it "has the member :mask" do
      assert_equal 3, GIMarshallingTests::NoTypeFlags[:mask]
    end
    it "has the member :mask2" do
      assert_equal 3, GIMarshallingTests::NoTypeFlags[:mask2]
    end
  end

  describe "GIMarshallingTests::NotSimpleStruct" do
    it "must be tested"
  end

  it "has the constant OVERRIDES_CONSTANT" do
    assert_equal 42, GIMarshallingTests::OVERRIDES_CONSTANT
  end

  describe "GIMarshallingTests::Object" do
    it "creates an instance using #new" do
      ob = GIMarshallingTests::Object.new 42
      assert_instance_of GIMarshallingTests::Object, ob
      assert_equal 42, ob.int
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

    let(:instance) { GIMarshallingTests::Object.new 42 }

    it "has a working method #call_vfunc_with_callback" do
      # NOTE: To call this method, the callback slot vfunc_with_callback has to
      # be filled in the GIMarshallingTests::Object class structure. The
      # GIMarshallingTests library doesn't do this.
      skip "Needs vfunc setup"
    end

    it "has a working method #full_in" do
      skip "This function is only found in the header"
    end

    it "has a working method #int8_in" do
      skip "Needs vfunc setup"
    end

    it "has a working method #int8_out" do
      skip "Needs vfunc setup"
    end

    # TODO: Avoid using common method names?
    it "has a working method #method" do
      instance.method
      pass
    end

    it "has a working method #method_array_in" do
      instance.method_array_in [-1, 0, 1, 2]
      pass
    end

    it "has a working method #method_array_inout" do
      res = instance.method_array_inout [-1, 0, 1, 2]
      assert_equal [-2, -1, 0, 1, 2], res.to_a
    end

    it "has a working method #method_array_out" do
      res = instance.method_array_out
      assert_equal [-1, 0, 1, 2], res.to_a
    end

    it "has a working method #method_array_return" do
      res = instance.method_array_return
      assert_equal [-1, 0, 1, 2], res.to_a
    end

    it "has a working method #method_int8_in" do
      skip "Needs vfunc setup"
    end

    it "has a working method #method_int8_out" do
      skip "Needs vfunc setup"
    end

    it "has a working method #method_variant_array_in" do
      skip "Needs vfunc setup"
    end

    it "has a working method #method_with_default_implementation" do
      instance.method_with_default_implementation 104
      assert_equal 104, instance.int
    end

    it "has a working method #none_in" do
      instance.none_in
      pass
    end

    it "has a working method #overridden_method" do
      instance.set_property("int", 0)
      instance.overridden_method
      pass
    end

    it "has a working method #vfunc_caller_allocated_out_parameter" do
      skip "Needs vfunc setup"
    end
    it "has a working method #vfunc_meth_with_error" do
      skip "Needs vfunc setup"
    end
    it "has a working method #vfunc_multiple_out_parameters" do
      skip "Needs vfunc setup"
    end
    it "has a working method #vfunc_one_out_parameter" do
      skip "Needs vfunc setup"
    end
    it "has a working method #vfunc_return_value_and_multiple_out_parameters" do
      skip "Needs vfunc setup"
    end
    it "has a working method #vfunc_return_value_and_one_out_parameter" do
      skip "Needs vfunc setup"
    end
    it "has a working method #vfunc_return_value_only" do
      skip "Needs vfunc setup"
    end
    it "has a working method #vfunc_with_callback" do
      skip "Needs vfunc setup"
    end

    it "has a property 'int' containing the argument to #new" do
      assert_equal 42, instance.get_property("int")
      instance.set_property("int", 13)
      assert_equal 13, instance.get_property("int")
    end

    it "has property accessors for the int property" do
      assert_equal 42, instance.int
      instance.int = 1
      assert_equal 1, instance.int
    end
  end

  describe "GIMarshallingTests::OverridesObject" do
    it "creates an instance using #new" do
      ob = GIMarshallingTests::OverridesObject.new
      assert_instance_of GIMarshallingTests::OverridesObject, ob
    end

    it "has a working function #returnv" do
      ob = GIMarshallingTests::OverridesObject.returnv
      assert_instance_of GIMarshallingTests::OverridesObject, ob
    end

    let(:instance) { GIMarshallingTests::OverridesObject.new }

    it "has a working method #method" do
      result = instance.method
      result.must_equal 42
    end

    it "does not have field accessor methods" do
      assert_raises(NoMethodError) { instance.parent_instance }
      assert_raises(NoMethodError) { instance.parent_instance = nil }
      assert_raises(NoMethodError) { instance.long_ }
      assert_raises(NoMethodError) { instance.long_ = 1 }
    end
  end

  describe "GIMarshallingTests::OverridesStruct" do
    let(:instance) { GIMarshallingTests::OverridesStruct.new }

    it "creates an instance using #new" do
      ob = GIMarshallingTests::OverridesStruct.new
      assert_instance_of GIMarshallingTests::OverridesStruct, ob
    end

    it "has a working method #method" do
      instance.method.must_equal 42
    end

    it "has a working function #returnv" do
      ob = GIMarshallingTests::OverridesStruct.returnv
      assert_instance_of GIMarshallingTests::OverridesStruct, ob
    end

    it "has a writable field long_" do
      instance.long_ = 43
      instance.long_.must_equal 43
    end
  end

  describe "GIMarshallingTests::PointerStruct" do
    it "creates an instance using #new" do
      ps = GIMarshallingTests::PointerStruct.new
      assert_instance_of GIMarshallingTests::PointerStruct, ps
    end

    let(:instance) { GIMarshallingTests::PointerStruct.new }

    it "has a working method #inv" do
      instance.long_ = 42
      instance.inv
      pass
    end

    it "has a writable field long_" do
      assert_equal 0, instance.long_
      instance.long_ = 1056
      assert_equal 1056, instance.long_
    end

    it "has a working function #returnv" do
      ob = GIMarshallingTests::PointerStruct.returnv
      assert_instance_of GIMarshallingTests::PointerStruct, ob
    end
  end

  describe "GIMarshallingTests::PropertiesObject" do
    it "creates an instance using #new" do
      ob = GIMarshallingTests::PropertiesObject.new
      assert_instance_of GIMarshallingTests::PropertiesObject, ob
    end

    it "has the property 'some-boolean'"
    it "has the property 'some-boxed-struct'"
    it "has the property 'some-char'"
    it "has the property 'some-double'"
    it "has the property 'some-float'"
    it "has the property 'some-int'"
    it "has the property 'some-int64'"
    it "has the property 'some-long'"
    it "has the property 'some-strv'"
    it "has the property 'some-uchar'"
    it "has the property 'some-uint'"
    it "has the property 'some-uint64'"
    it "has the property 'some-ulong'"
  end

  describe "GIMarshallingTests::SecondEnum" do
    it "has the member :secondvalue1" do
      assert_equal 0, GIMarshallingTests::SecondEnum[:secondvalue1]
    end
    it "has the member :secondvalue2" do
      assert_equal 1, GIMarshallingTests::SecondEnum[:secondvalue2]
    end
  end

  describe "GIMarshallingTests::SimpleStruct" do
    it "creates an instance using #new" do
      ss = GIMarshallingTests::SimpleStruct.new
      assert_instance_of GIMarshallingTests::SimpleStruct, ss
    end

    let(:instance) { GIMarshallingTests::SimpleStruct.new }

    it "has a working method #inv" do
      instance.long_ = 6
      instance.int8 = 7
      instance.inv
      pass
    end

    it "has a working method #method" do
      instance.long_ = 6
      instance.int8 = 7
      instance.method
      pass
    end

    it "has a writable field long_" do
      assert_equal 0, instance.long_
      instance.long_ = 1056
      assert_equal 1056, instance.long_
    end

    it "has a writable field int8" do
      assert_equal 0, instance.int8
      instance.int8 = -43
      assert_equal(-43, instance.int8)
    end

    it "has a working function #returnv" do
      ss = GIMarshallingTests::SimpleStruct.returnv
      assert_instance_of GIMarshallingTests::SimpleStruct, ss
    end
  end

  describe "GIMarshallingTests::SubObject" do
    it "creates an instance using #new" do
      so = GIMarshallingTests::SubObject.new 42
      assert_instance_of GIMarshallingTests::SubObject, so
    end

    let(:instance) { GIMarshallingTests::SubObject.new 0 }

    it "has a working method #overwritten_method" do
      instance.overwritten_method
      pass
    end

    it "has a working method #sub_method" do
      instance.sub_method
      pass
    end

    it "does not have field accessors" do
      assert_raises(NoMethodError) { instance.parent_instance }
      assert_raises(NoMethodError) { instance.parent_instance = nil }
    end
  end

  describe "GIMarshallingTests::SubSubObject" do
    it "creates an instance using #new" do
      so = GIMarshallingTests::SubSubObject.new 42
      assert_instance_of GIMarshallingTests::SubSubObject, so
    end

    let(:instance) { GIMarshallingTests::SubSubObject.new 0 }

    it "does not have field accessors" do
      assert_raises(NoMethodError) { instance.parent_instance }
      assert_raises(NoMethodError) { instance.parent_instance = nil }
    end
  end

  describe "GIMarshallingTests::Union" do
    it "creates an instance with #new" do
      u = GIMarshallingTests::Union.new
      assert_instance_of GIMarshallingTests::Union, u
    end

    let(:instance) { GIMarshallingTests::Union.new }

    it "has a writable field long_" do
      assert_equal 0, instance.long_
      instance.long_ = 1056
      assert_equal 1056, instance.long_
    end

    it "has a working method #inv" do
      instance.long_ = 42
      instance.inv
      pass
    end

    it "has a working method #method" do
      instance.long_ = 42
      instance.method
      pass
    end

    it "has a working function #inout" do
      skip "This function is defined in the header but not implemented"
    end

    it "has a working function #out" do
      skip "This function is defined in the header but not implemented"
    end

    it "has a working function #returnv" do
      u = GIMarshallingTests::Union.returnv
      assert_instance_of GIMarshallingTests::Union, u
    end
  end

  it "has a working function #array_enum_in" do
    GIMarshallingTests.array_enum_in [:value1, :value2, :value3]
  end

  it "has a working function #array_fixed_inout" do
    res = GIMarshallingTests.array_fixed_inout [-1, 0, 1, 2]
    assert_equal [2, 1, 0, -1], res.to_a
  end

  it "has a working function #array_fixed_int_in" do
    GIMarshallingTests.array_fixed_int_in [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_fixed_int_return" do
    res = GIMarshallingTests.array_fixed_int_return
    assert_equal [-1, 0, 1, 2], res.to_a
  end

  it "has a working function #array_fixed_out" do
    res = GIMarshallingTests.array_fixed_out
    assert_equal [-1, 0, 1, 2], res.to_a
  end

  it "has a working function #array_fixed_out_struct" do
    res = GIMarshallingTests.array_fixed_out_struct
    assert_equal [[7, 6], [6, 7]], res.map {|s| [s.long_, s.int8]}
  end

  it "has a working function #array_fixed_short_in" do
    GIMarshallingTests.array_fixed_short_in [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_fixed_short_return" do
    res = GIMarshallingTests.array_fixed_short_return
    assert_equal [-1, 0, 1, 2], res.to_a
  end

  it "has a working function #array_gvariant_container_in" do
    v1 = GLib::Variant.new_int32(27)
    v2 = GLib::Variant.new_string("Hello")
    result = GIMarshallingTests.array_gvariant_container_in [v1, v2]
    arr = result.to_a
    arr.size.must_equal 2
    arr[0].get_int32.must_equal 27
    arr[1].get_string.must_equal "Hello"
  end

  it "has a working function #array_gvariant_full_in" do
    v1 = GLib::Variant.new_int32(27)
    v2 = GLib::Variant.new_string("Hello")
    result = GIMarshallingTests.array_gvariant_full_in [v1, v2]
    arr = result.to_a
    arr.size.must_equal 2
    arr[0].get_int32.must_equal 27
    arr[1].get_string.must_equal "Hello"
  end

  it "has a working function #array_gvariant_none_in" do
    v1 = GLib::Variant.new_int32(27)
    v2 = GLib::Variant.new_string("Hello")
    result = GIMarshallingTests.array_gvariant_none_in [v1, v2]
    arr = result.to_a
    arr.size.must_equal 2
    arr[0].get_int32.must_equal 27
    arr[1].get_string.must_equal "Hello"
  end

  it "has a working function #array_in" do
    GIMarshallingTests.array_in [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_in_guint64_len" do
    GIMarshallingTests.array_in_guint64_len [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_in_guint8_len" do
    GIMarshallingTests.array_in_guint8_len [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_in_len_before" do
    GIMarshallingTests.array_in_len_before [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_in_len_zero_terminated" do
    GIMarshallingTests.array_in_len_zero_terminated [-1, 0, 1, 2]
    pass
  end

  it "has a working function #array_in_nonzero_nonlen" do
    GIMarshallingTests.array_in_nonzero_nonlen 1, 'abcd'.bytes.to_a
    pass
  end

  it "has a working function #array_inout" do
    res = GIMarshallingTests.array_inout [-1, 0, 1, 2]
    assert_equal [-2, -1, 0, 1, 2], res.to_a
  end

  it "has a working function #array_inout_etc" do
    arr, sum = GIMarshallingTests.array_inout_etc 42, [-1, 0, 1, 2], 24
    arr.to_a.must_equal [42, -1, 0, 1, 24]
    sum.must_equal 42 + 24
  end

  it "has a working function #array_out" do
    res = GIMarshallingTests.array_out
    assert_equal  [-1, 0, 1, 2], res.to_a
  end

  it "has a working function #array_out_etc" do
    arr, sum = GIMarshallingTests.array_out_etc 42, 24
    arr.to_a.must_equal [42, 0, 1, 24]
    sum.must_equal 42 + 24
  end

  it "has a working function #array_return" do
    res = GIMarshallingTests.array_return
    assert_equal  [-1, 0, 1, 2], res.to_a
  end

  it "has a working function #array_return_etc" do
    arr, sum = GIMarshallingTests.array_return_etc 42, 24
    arr.to_a.must_equal [42, 0, 1, 24]
    sum.must_equal 42 + 24
  end

  it "has a working function #array_simple_struct_in" do
    skip
  end

  it "has a working function #array_string_in" do
    GIMarshallingTests.array_string_in ["foo", "bar"]
    pass
  end

  it "has a working function #array_struct_in" do
    skip
  end
  it "has a working function #array_struct_take_in" do
    skip
  end

  it "has a working function #array_uint8_in" do
    arr = "abcd".bytes.to_a
    GIMarshallingTests.array_uint8_in arr
    pass
  end

  it "has a working function #array_zero_terminated_in" do
    GIMarshallingTests.array_zero_terminated_in ["0", "1", "2"]
    pass
  end

  it "has a working function #array_zero_terminated_inout" do
    skip
  end

  it "has a working function #array_zero_terminated_out" do
    res = GIMarshallingTests.array_zero_terminated_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #array_zero_terminated_return" do
    res = GIMarshallingTests.array_zero_terminated_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #array_zero_terminated_return_null" do
    skip
  end
  it "has a working function #array_zero_terminated_return_struct" do
    skip
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
    bx.long_ = 42
    res = GIMarshallingTests.boxed_struct_inout bx
    assert_equal 0, res.long_
  end

  it "has a working function #boxed_struct_out" do
    res = GIMarshallingTests.boxed_struct_out
    assert_equal 42, res.long_
  end

  it "has a working function #boxed_struct_returnv" do
    res = GIMarshallingTests.boxed_struct_returnv
    assert_equal 42, res.long_
    assert_equal ["0", "1", "2"], res.g_strv.to_a
  end

  it "has a working function #bytearray_full_return" do
    ret = GIMarshallingTests.bytearray_full_return
    assert_instance_of GLib::ByteArray, ret
    assert_includes(
      ["0123".bytes.to_a, "\x001\xFF3".bytes.to_a],
      ret.to_string.bytes.to_a)
  end

  it "has a working function #bytearray_none_in" do
    val = GIMarshallingTests.bytearray_full_return.to_string
    ba = GLib::ByteArray.new
    ba = ba.append val
    GIMarshallingTests.bytearray_none_in ba
    pass
  end

  it "has a working function #callback_multiple_out_parameters" do
    skip
  end
  it "has a working function #callback_one_out_parameter" do
    skip
  end
  it "has a working function #callback_return_value_and_multiple_out_parameters" do
    skip
  end
  it "has a working function #callback_return_value_and_one_out_parameter" do
    skip
  end
  it "has a working function #callback_return_value_only" do
    skip
  end

  it "has a working function #double_in" do
    GIMarshallingTests.double_in Float::MAX
    pass
  end

  it "has a working function #double_inout" do
    ret = GIMarshallingTests.double_inout Float::MAX
    assert_in_epsilon 2.225e-308, ret
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
    arr = [-1, 0, 1, 2]
    GIMarshallingTests.garray_int_none_in arr
    pass
  end

  it "has a working function #garray_int_none_return" do
    arr = GIMarshallingTests.garray_int_none_return
    assert_equal [-1, 0, 1, 2], arr.to_a
  end

  it "has a working function #garray_uint64_none_in" do
    skip
  end
  it "has a working function #garray_uint64_none_return" do
    skip
  end
  it "has a working function #garray_utf8_container_inout" do
    skip
  end

  it "has a working function #garray_utf8_container_out" do
    res = GIMarshallingTests.garray_utf8_container_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #garray_utf8_container_return" do
    res = GIMarshallingTests.garray_utf8_container_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #garray_utf8_full_inout" do
    arr = ["0", "1", "2"]
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
    arr = ["0", "1", "2"]
    GIMarshallingTests.garray_utf8_none_in arr
    pass
  end

  it "has a working function #garray_utf8_none_inout" do
    arr = ["0", "1", "2"]
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

  it "has a working function #gerror_out" do
    skip
  end
  it "has a working function #gerror_out_transfer_none" do
    skip
  end
  it "has a working function #gerror_return" do
    skip
  end

  it "has a working function #ghashtable_int_none_in" do
    GIMarshallingTests.ghashtable_int_none_in(
      {-1 => 1, 0 => 0, 1 => -1, 2 => -2})
  end

  it "has a working function #ghashtable_int_none_return" do
    gh = GIMarshallingTests.ghashtable_int_none_return
    assert_equal({-1 => 1, 0 => 0, 1 => -1, 2 => -2}, gh.to_hash)
  end

  it "has a working function #ghashtable_utf8_container_in" do
    skip "This function is defined in the header but not implemented"
  end

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

  it "has a working function #ghashtable_utf8_full_in" do
    skip "This function is defined in the header but not implemented"
  end

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

  it "has a working function #glist_int_none_in" do
    GIMarshallingTests.glist_int_none_in [-1, 0, 1, 2]
    pass
  end

  it "has a working function #glist_int_none_return" do
    res = GIMarshallingTests.glist_int_none_return
    assert_equal [-1, 0, 1, 2], res.to_a
  end

  it "has a working function #glist_uint32_none_in" do
    skip
  end
  it "has a working function #glist_uint32_none_return" do
    skip
  end

  it "has a working function #glist_utf8_container_inout" do
    res = GIMarshallingTests.glist_utf8_container_inout ["0", "1", "2"]
    assert_equal ["-2", "-1", "0", "1"], res.to_a
  end

  it "has a working function #glist_utf8_container_out" do
    res = GIMarshallingTests.glist_utf8_container_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #glist_utf8_container_return" do
    res = GIMarshallingTests.glist_utf8_container_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #glist_utf8_full_inout" do
    res = GIMarshallingTests.glist_utf8_full_inout ["0", "1", "2"]
    assert_equal ["-2", "-1", "0", "1"], res.to_a
  end

  it "has a working function #glist_utf8_full_out" do
    res = GIMarshallingTests.glist_utf8_full_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #glist_utf8_full_return" do
    res = GIMarshallingTests.glist_utf8_full_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #glist_utf8_none_in" do
    GIMarshallingTests.glist_utf8_none_in ["0", "1", "2"]
  end

  it "has a working function #glist_utf8_none_inout" do
    res = GIMarshallingTests.glist_utf8_none_inout ["0", "1", "2"]
    assert_equal ["-2", "-1", "0", "1"], res.to_a
  end

  it "has a working function #glist_utf8_none_out" do
    res = GIMarshallingTests.glist_utf8_none_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #glist_utf8_none_return" do
    res = GIMarshallingTests.glist_utf8_none_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gptrarray_utf8_container_inout" do
    skip
  end
  it "has a working function #gptrarray_utf8_container_out" do
    skip
  end
  it "has a working function #gptrarray_utf8_container_return" do
    skip
  end
  it "has a working function #gptrarray_utf8_full_inout" do
    skip
  end
  it "has a working function #gptrarray_utf8_full_out" do
    skip
  end
  it "has a working function #gptrarray_utf8_full_return" do
    skip
  end
  it "has a working function #gptrarray_utf8_none_in" do
    skip
  end
  it "has a working function #gptrarray_utf8_none_inout" do
    skip
  end
  it "has a working function #gptrarray_utf8_none_out" do
    skip
  end
  it "has a working function #gptrarray_utf8_none_return" do
    skip
  end

  it "has a working function #gslist_int_none_in" do
    GIMarshallingTests.gslist_int_none_in [-1, 0, 1, 2]
    pass
  end

  it "has a working function #gslist_int_none_return" do
    res = GIMarshallingTests.gslist_int_none_return
    assert_equal [-1, 0, 1, 2], res.to_a
  end

  it "has a working function #gslist_utf8_container_inout" do
    res = GIMarshallingTests.gslist_utf8_container_inout ["0", "1", "2"]
    assert_equal ["-2", "-1", "0", "1"], res.to_a
  end

  it "has a working function #gslist_utf8_container_out" do
    res = GIMarshallingTests.gslist_utf8_container_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gslist_utf8_container_return" do
    res = GIMarshallingTests.gslist_utf8_container_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gslist_utf8_full_inout" do
    res = GIMarshallingTests.gslist_utf8_full_inout ["0", "1", "2"]
    assert_equal ["-2", "-1", "0", "1"], res.to_a
  end

  it "has a working function #gslist_utf8_full_out" do
    res = GIMarshallingTests.gslist_utf8_full_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gslist_utf8_full_return" do
    res = GIMarshallingTests.gslist_utf8_full_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gslist_utf8_none_in" do
    GIMarshallingTests.gslist_utf8_none_in ["0", "1", "2"]
    pass
  end

  it "has a working function #gslist_utf8_none_inout" do
    res = GIMarshallingTests.gslist_utf8_none_inout ["0", "1", "2"]
    assert_equal ["-2", "-1", "0", "1"], res.to_a
  end

  it "has a working function #gslist_utf8_none_out" do
    res = GIMarshallingTests.gslist_utf8_none_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gslist_utf8_none_return" do
    res = GIMarshallingTests.gslist_utf8_none_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gstrv_in" do
    GIMarshallingTests.gstrv_in ["0", "1", "2"]
    pass
  end

  it "has a working function #gstrv_inout" do
    res = GIMarshallingTests.gstrv_inout ["0", "1", "2"]
    assert_equal ["-1", "0", "1", "2"], res.to_a
  end

  it "has a working function #gstrv_out" do
    res = GIMarshallingTests.gstrv_out
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gstrv_return" do
    res = GIMarshallingTests.gstrv_return
    assert_equal ["0", "1", "2"], res.to_a
  end

  it "has a working function #gtype_in" do
    skip
  end

  it "has a working function #gtype_inout" do
    none = GObject.type_from_name "void"
    res = GIMarshallingTests.gtype_inout none
    name = GObject.type_name res
    assert_equal "gint", name
  end

  it "has a working function #gtype_out" do
    res = GIMarshallingTests.gtype_out
    name = GObject.type_name res
    assert_equal "void", name
  end

  it "has a working function #gtype_return" do
    res = GIMarshallingTests.gtype_return
    name = GObject.type_name res
    assert_equal "void", name
  end

  it "has a working function #gtype_string_in" do
    skip
  end
  it "has a working function #gtype_string_out" do
    skip
  end
  it "has a working function #gtype_string_return" do
    skip
  end
  it "has a working function #gvalue_flat_array" do
    skip
  end
  it "has a working function #gvalue_flat_array_round_trip" do
    skip
  end

  it "has a working function #gvalue_in" do
    GIMarshallingTests.gvalue_in GObject::Value.wrap_ruby_value(42)
    GIMarshallingTests.gvalue_in 42
    pass
  end

  it "has a working function #gvalue_in_enum" do
    gv = GObject::Value.new
    gv.init GIMarshallingTests::GEnum.get_gtype
    gv.set_enum GIMarshallingTests::GEnum[:value3]
    GIMarshallingTests.gvalue_in_enum gv
    pass
  end

  it "has a working function #gvalue_in_with_type" do
    skip
  end

  it "has a working function #gvalue_inout" do
    res = GIMarshallingTests.gvalue_inout GObject::Value.wrap_ruby_value(42)
    assert_equal "42", res.ruby_value

    res = GIMarshallingTests.gvalue_inout 42
    assert_equal "42", res.ruby_value
  end

  it "has a working function #gvalue_int64_in" do
    skip
  end
  it "has a working function #gvalue_int64_out" do
    skip
  end

  it "has a working function #gvalue_out" do
    res = GIMarshallingTests.gvalue_out
    assert_equal 42, res.ruby_value
  end

  it "has a working function #gvalue_out_caller_allocates" do
    skip
  end

  it "has a working function #gvalue_return" do
    res = GIMarshallingTests.gvalue_return
    assert_equal 42, res.ruby_value
  end

  it "has a working function #init_function" do
    skip
  end

  it "has a working function #int16_in_max" do
    GIMarshallingTests.int16_in_max 0x7fff
    pass
  end

  it "has a working function #int16_in_min" do
    GIMarshallingTests.int16_in_min(-0x8000)
    pass
  end

  it "has a working function #int16_inout_max_min" do
    res = GIMarshallingTests.int16_inout_max_min 0x7fff
    assert_equal res, -0x8000
  end

  it "has a working function #int16_inout_min_max" do
    res = GIMarshallingTests.int16_inout_min_max(-0x8000)
    assert_equal 0x7fff, res
  end

  it "has a working function #int16_out_max" do
    res = GIMarshallingTests.int16_out_max
    assert_equal 0x7fff, res
  end

  it "has a working function #int16_out_min" do
    res = GIMarshallingTests.int16_out_min
    assert_equal(-0x8000, res)
  end

  it "has a working function #int16_return_max" do
    res = GIMarshallingTests.int16_return_max
    assert_equal 0x7fff, res
  end

  it "has a working function #int16_return_min" do
    res = GIMarshallingTests.int16_return_min
    assert_equal(-0x8000, res)
  end

  it "has a working function #int32_in_max" do
    GIMarshallingTests.int32_in_max 0x7fffffff
    pass
  end

  it "has a working function #int32_in_min" do
    GIMarshallingTests.int32_in_min(-0x80000000)
    pass
  end

  it "has a working function #int32_inout_max_min" do
    res = GIMarshallingTests.int32_inout_max_min 0x7fffffff
    assert_equal(-0x80000000, res)
  end

  it "has a working function #int32_inout_min_max" do
    res = GIMarshallingTests.int32_inout_min_max(-0x80000000)
    assert_equal 0x7fffffff, res
  end

  it "has a working function #int32_out_max" do
    res = GIMarshallingTests.int32_out_max
    assert_equal 0x7fffffff, res
  end

  it "has a working function #int32_out_min" do
    res = GIMarshallingTests.int32_out_min
    assert_equal(-0x80000000, res)
  end

  it "has a working function #int32_return_max" do
    res = GIMarshallingTests.int32_return_max
    assert_equal 0x7fffffff, res
  end

  it "has a working function #int32_return_min" do
    res = GIMarshallingTests.int32_return_min
    assert_equal(-0x80000000, res)
  end

  it "has a working function #int64_in_max" do
    GIMarshallingTests.int64_in_max 0x7fffffffffffffff
    pass
  end

  it "has a working function #int64_in_min" do
    GIMarshallingTests.int64_in_min(-0x8000000000000000)
    pass
  end

  it "has a working function #int64_inout_max_min" do
    res = GIMarshallingTests.int64_inout_max_min 0x7fffffffffffffff
    assert_equal(-0x8000000000000000, res)
  end

  it "has a working function #int64_inout_min_max" do
    res = GIMarshallingTests.int64_inout_min_max(-0x8000000000000000)
    assert_equal 0x7fffffffffffffff, res
  end

  it "has a working function #int64_out_max" do
    res = GIMarshallingTests.int64_out_max
    assert_equal 0x7fffffffffffffff, res
  end

  it "has a working function #int64_out_min" do
    res = GIMarshallingTests.int64_out_min
    assert_equal(-0x8000000000000000, res)
  end

  it "has a working function #int64_return_max" do
    res = GIMarshallingTests.int64_return_max
    assert_equal 0x7fffffffffffffff, res
  end

  it "has a working function #int64_return_min" do
    res = GIMarshallingTests.int64_return_min
    assert_equal(-0x8000000000000000, res)
  end

  it "has a working function #int8_in_max" do
    GIMarshallingTests.int8_in_max 0x7f
    pass
  end

  it "has a working function #int8_in_min" do
    GIMarshallingTests.int8_in_min(-0x80)
    pass
  end

  it "has a working function #int8_inout_max_min" do
    res = GIMarshallingTests.int8_inout_max_min 0x7f
    assert_equal(-0x80, res)
  end

  it "has a working function #int8_inout_min_max" do
    res = GIMarshallingTests.int8_inout_min_max(-0x80)
    assert_equal 0x7f, res
  end

  it "has a working function #int8_out_max" do
    res = GIMarshallingTests.int8_out_max
    assert_equal 0x7f, res
  end

  it "has a working function #int8_out_min" do
    res = GIMarshallingTests.int8_out_min
    assert_equal(-0x80, res)
  end

  it "has a working function #int8_return_max" do
    res = GIMarshallingTests.int8_return_max
    assert_equal 0x7f, res
  end

  it "has a working function #int8_return_min" do
    res = GIMarshallingTests.int8_return_min
    assert_equal(-0x80, res)
  end

  it "has a working function #int_in_max" do
    GIMarshallingTests.int_in_max 0x7fffffff
    pass
  end

  it "has a working function #int_in_min" do
    GIMarshallingTests.int_in_min(-0x80000000)
    pass
  end

  it "has a working function #int_inout_max_min" do
    res = GIMarshallingTests.int_inout_max_min 0x7fffffff
    assert_equal(-0x80000000, res)
  end

  it "has a working function #int_inout_min_max" do
    res = GIMarshallingTests.int_inout_min_max(-0x80000000)
    assert_equal 0x7fffffff, res
  end

  it "has a working function #int_out_max" do
    res = GIMarshallingTests.int_out_max
    assert_equal 0x7fffffff, res
  end

  it "has a working function #int_out_min" do
    res = GIMarshallingTests.int_out_min
    assert_equal(-0x80000000, res)
  end

  it "has a working function #int_out_out" do
    res = GIMarshallingTests.int_out_out
    assert_equal [6, 7], res
  end

  it "has a working function #int_return_max" do
    res = GIMarshallingTests.int_return_max
    assert_equal 0x7fffffff, res
  end

  it "has a working function #int_return_min" do
    res = GIMarshallingTests.int_return_min
    assert_equal(-0x80000000, res)
  end

  it "has a working function #int_return_out" do
    res = GIMarshallingTests.int_return_out
    assert_equal [6, 7], res
  end

  it "has a working function #int_three_in_three_out" do
    res = GIMarshallingTests.int_three_in_three_out 4, 5, 6
    assert_equal [4, 5, 6], res
  end

  it "has a working function #long_in_max" do
    GIMarshallingTests.long_in_max max_long
    pass
  end

  it "has a working function #long_in_min" do
    GIMarshallingTests.long_in_min min_long
    pass
  end

  it "has a working function #long_inout_max_min" do
    res = GIMarshallingTests.long_inout_max_min max_long
    assert_equal min_long, res
  end

  it "has a working function #long_inout_min_max" do
    res = GIMarshallingTests.long_inout_min_max min_long
    assert_equal max_long, res
  end

  it "has a working function #long_out_max" do
    res = GIMarshallingTests.long_out_max
    assert_equal max_long, res
  end

  it "has a working function #long_out_min" do
    res = GIMarshallingTests.long_out_min
    assert_equal min_long, res
  end

  it "has a working function #long_return_max" do
    res = GIMarshallingTests.long_return_max
    assert_equal max_long, res
  end

  it "has a working function #long_return_min" do
    res = GIMarshallingTests.long_return_min
    assert_equal min_long, res
  end

  it "has a working function #multi_array_key_value_in" do
    skip
  end

  it "has a working function #no_type_flags_in" do
    GIMarshallingTests.no_type_flags_in :value2
    pass
  end

  it "has a working function #no_type_flags_in_zero" do
    GIMarshallingTests.no_type_flags_in_zero 0
    pass
  end

  it "has a working function #no_type_flags_inout" do
    res = GIMarshallingTests.no_type_flags_inout :value2
    assert_equal :value1, res
  end

  it "has a working function #no_type_flags_out" do
    res = GIMarshallingTests.no_type_flags_out
    assert_equal :value2, res
  end

  it "has a working function #no_type_flags_returnv" do
    res = GIMarshallingTests.no_type_flags_returnv
    assert_equal :value2, res
  end

  it "has a working function #overrides_struct_returnv" do
    skip
  end
  it "has a working function #param_spec_out" do
    skip
  end
  it "has a working function #param_spec_return" do
    skip
  end

  it "has a working function #pointer_in_return" do
    ptr = FFI::MemoryPointer.new 1
    res = GIMarshallingTests.pointer_in_return ptr
    assert_equal ptr.address, res.address
  end

  it "has a working function #pointer_struct_get_type" do
    res = GIMarshallingTests.pointer_struct_get_type
    gtype = GObject.type_from_name "GIMarshallingTestsPointerStruct"
    assert_equal gtype, res
  end

  it "has a working function #pointer_struct_returnv" do
    res = GIMarshallingTests.pointer_struct_returnv
    assert_instance_of GIMarshallingTests::PointerStruct, res
    assert_equal 42, res.long_
  end

  it "has a working function #return_gvalue_flat_array" do
    skip
  end

  it "has a working function #short_in_max" do
    GIMarshallingTests.short_in_max 0x7fff
    pass
  end

  it "has a working function #short_in_min" do
    GIMarshallingTests.short_in_min(-0x8000)
    pass
  end

  it "has a working function #short_inout_max_min" do
    res = GIMarshallingTests.short_inout_max_min 0x7fff
    assert_equal(-0x8000, res)
  end

  it "has a working function #short_inout_min_max" do
    res = GIMarshallingTests.short_inout_min_max(-0x8000)
    assert_equal 0x7fff, res
  end

  it "has a working function #short_out_max" do
    res = GIMarshallingTests.short_out_max
    assert_equal 0x7fff, res
  end

  it "has a working function #short_out_min" do
    res = GIMarshallingTests.short_out_min
    assert_equal(-0x8000, res)
  end

  it "has a working function #short_return_max" do
    res = GIMarshallingTests.short_return_max
    assert_equal 0x7fff, res
  end

  it "has a working function #short_return_min" do
    res = GIMarshallingTests.short_return_min
    assert_equal(-0x8000, res)
  end

  it "has a working function #simple_struct_returnv" do
    res = GIMarshallingTests.simple_struct_returnv
    assert_instance_of GIMarshallingTests::SimpleStruct, res
    assert_equal 6, res.long_
    assert_equal 7, res.int8
  end

  it "has a working function #size_in" do
    GIMarshallingTests.size_in max_size_t
  end

  it "has a working function #size_inout" do
    res = GIMarshallingTests.size_inout max_size_t
    assert_equal 0, res
  end

  it "has a working function #size_out" do
    res = GIMarshallingTests.size_out
    assert_equal max_size_t, res
  end

  it "has a working function #size_return" do
    res = GIMarshallingTests.size_return
    assert_equal max_size_t, res
  end

  it "has a working function #ssize_in_max" do
    GIMarshallingTests.ssize_in_max max_ssize_t
    pass
  end

  it "has a working function #ssize_in_min" do
    GIMarshallingTests.ssize_in_min min_ssize_t
    pass
  end

  it "has a working function #ssize_inout_max_min" do
    res = GIMarshallingTests.ssize_inout_max_min max_ssize_t
    assert_equal min_ssize_t, res
  end

  it "has a working function #ssize_inout_min_max" do
    res = GIMarshallingTests.ssize_inout_min_max min_ssize_t
    assert_equal max_ssize_t, res
  end

  it "has a working function #ssize_out_max" do
    res = GIMarshallingTests.ssize_out_max
    assert_equal max_ssize_t, res
  end

  it "has a working function #ssize_out_min" do
    res = GIMarshallingTests.ssize_out_min
    assert_equal min_ssize_t, res
  end

  it "has a working function #ssize_return_max" do
    res = GIMarshallingTests.ssize_return_max
    assert_equal max_ssize_t, res
  end

  it "has a working function #ssize_return_min" do
    res = GIMarshallingTests.ssize_return_min
    assert_equal min_ssize_t, res
  end

  it "has a working function #test_interface_test_int8_in" do
    skip
  end

  it "has a working function #time_t_in" do
    GIMarshallingTests.time_t_in 1234567890
    pass
  end

  it "has a working function #time_t_inout" do
    res = GIMarshallingTests.time_t_inout 1234567890
    assert_equal 0, res
  end

  it "has a working function #time_t_out" do
    res = GIMarshallingTests.time_t_out
    assert_equal 1234567890, res
  end

  it "has a working function #time_t_return" do
    res = GIMarshallingTests.time_t_return
    assert_equal 1234567890, res
  end

  it "has a working function #uint16_in" do
    GIMarshallingTests.uint16_in 0xffff
    pass
  end

  it "has a working function #uint16_inout" do
    res = GIMarshallingTests.uint16_inout 0xffff
    assert_equal 0, res
  end

  it "has a working function #uint16_out" do
    res = GIMarshallingTests.uint16_out
    assert_equal 0xffff, res
  end

  it "has a working function #uint16_return" do
    res = GIMarshallingTests.uint16_return
    assert_equal 0xffff, res
  end

  it "has a working function #uint32_in" do
    GIMarshallingTests.uint32_in 0xffffffff
  end

  it "has a working function #uint32_inout" do
    res = GIMarshallingTests.uint32_inout 0xffffffff
    assert_equal 0, res
  end

  it "has a working function #uint32_out" do
    res = GIMarshallingTests.uint32_out
    assert_equal 0xffffffff, res
  end

  it "has a working function #uint32_return" do
    res = GIMarshallingTests.uint32_return
    assert_equal 0xffffffff, res
  end

  it "has a working function #uint64_in" do
    GIMarshallingTests.uint64_in 0xffff_ffff_ffff_ffff
    pass
  end

  it "has a working function #uint64_inout" do
    res = GIMarshallingTests.uint64_inout 0xffff_ffff_ffff_ffff
    assert_equal 0, res
  end

  it "has a working function #uint64_out" do
    res = GIMarshallingTests.uint64_out
    assert_equal 0xffff_ffff_ffff_ffff, res
  end

  it "has a working function #uint64_return" do
    res = GIMarshallingTests.uint64_return
    assert_equal 0xffff_ffff_ffff_ffff, res
  end

  it "has a working function #uint8_in" do
    GIMarshallingTests.uint8_in 0xff
  end

  it "has a working function #uint8_inout" do
    res = GIMarshallingTests.uint8_inout 0xff
    assert_equal 0, res
  end

  it "has a working function #uint8_out" do
    res = GIMarshallingTests.uint8_out
    assert_equal 0xff, res
  end

  it "has a working function #uint8_return" do
    res = GIMarshallingTests.uint8_return
    assert_equal 0xff, res
  end

  it "has a working function #uint_in" do
    GIMarshallingTests.uint_in max_uint
    pass
  end

  it "has a working function #uint_inout" do
    res = GIMarshallingTests.uint_inout max_uint
    assert_equal 0, res
  end

  it "has a working function #uint_out" do
    res = GIMarshallingTests.uint_out
    assert_equal max_uint, res
  end

  it "has a working function #uint_return" do
    res = GIMarshallingTests.uint_return
    assert_equal max_uint, res
  end

  it "has a working function #ulong_in" do
    GIMarshallingTests.ulong_in max_ulong
  end

  it "has a working function #ulong_inout" do
    res = GIMarshallingTests.ulong_inout max_ulong
    assert_equal 0, res
  end

  it "has a working function #ulong_out" do
    res = GIMarshallingTests.ulong_out
    assert_equal max_ulong, res
  end

  it "has a working function #ulong_return" do
    res = GIMarshallingTests.ulong_return
    assert_equal max_ulong, res
  end

  it "has a working function #union_inout" do
    skip "This function is defined in the header but not implemented"
  end

  it "has a working function #union_out" do
    skip "This function is defined in the header but not implemented"
  end

  it "has a working function #union_returnv" do
    res = GIMarshallingTests.union_returnv
    assert_instance_of GIMarshallingTests::Union, res
    assert_equal 42, res.long_
  end

  it "has a working function #ushort_in" do
    GIMarshallingTests.ushort_in max_ushort
    pass
  end

  it "has a working function #ushort_inout" do
    res = GIMarshallingTests.ushort_inout max_ushort
    assert_equal 0, res
  end

  it "has a working function #ushort_out" do
    res = GIMarshallingTests.ushort_out
    assert_equal max_ushort, res
  end

  it "has a working function #ushort_return" do
    res = GIMarshallingTests.ushort_return
    assert_equal max_ushort, res
  end

  it "has a working function #utf8_dangling_out" do
    res = GIMarshallingTests.utf8_dangling_out
    assert_nil res
  end

  it "has a working function #utf8_full_in" do
    skip "This function is defined in the header but not implemented"
  end


  it "has a working function #utf8_full_inout" do
    res = GIMarshallingTests.utf8_full_inout "const ♥ utf8"
    assert_equal "", res
  end

  it "has a working function #utf8_full_out" do
    res = GIMarshallingTests.utf8_full_out
    assert_equal "const ♥ utf8", res
  end

  it "has a working function #utf8_full_return" do
    res = GIMarshallingTests.utf8_full_return
    assert_equal "const ♥ utf8", res
  end

  it "has a working function #utf8_none_in" do
    GIMarshallingTests.utf8_none_in "const ♥ utf8"
    pass
  end

  it "has a working function #utf8_none_inout" do
    res = GIMarshallingTests.utf8_none_inout "const ♥ utf8"
    assert_equal "", res
  end

  it "has a working function #utf8_none_out" do
    res = GIMarshallingTests.utf8_none_out
    assert_equal "const ♥ utf8", res
  end

  it "has a working function #utf8_none_return" do
    res = GIMarshallingTests.utf8_none_return
    assert_equal "const ♥ utf8", res
  end
end
