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

    it "has the method #inv" do
      bx = GIMarshallingTests::BoxedStruct.new
      bx[:long_] = 42
      bx.inv
      pass
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
    end
  end
end

