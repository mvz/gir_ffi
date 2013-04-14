require 'gir_ffi_test_helper'

describe GObject::Helper do
  before do
    GirFFI.setup :Regress
  end

  describe "#signal_arguments_to_gvalue_array" do
    describe "the result of wrapping test-with-static-scope-arg" do
      setup do
        o = Regress::TestSubObj.new
        b = Regress::TestSimpleBoxedA.new

        @gva = GObject::Helper.signal_arguments_to_gvalue_array(
          "test-with-static-scope-arg", o, b)
      end

      should "be a GObject::ValueArray" do
        assert_instance_of GObject::ValueArray, @gva
      end

      should "contain two values" do
        assert_equal 2, @gva.n_values
      end

      should "have a first value with GType for TestSubObj" do
        assert_equal Regress::TestSubObj.get_gtype, (@gva.get_nth 0).current_gtype
      end

      should "have a second value with GType for TestSimpleBoxedA" do
        assert_equal Regress::TestSimpleBoxedA.get_gtype, (@gva.get_nth 1).current_gtype
      end
    end
  end

  describe "#signal_argument_to_gvalue" do
    it "maps a :utf8 argument to a string-valued GValue" do
      stub(arg_t = Object.new).g_type { GObject::TYPE_STRING }
      stub(info = Object.new).argument_type { arg_t }
      val = GObject::Helper.signal_argument_to_gvalue(info, "foo")
      assert_instance_of GObject::Value, val
      assert_equal "foo", val.get_string
    end
  end
end
