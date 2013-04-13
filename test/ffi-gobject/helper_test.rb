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

        @gva =
          GObject::Helper.signal_arguments_to_gvalue_array(
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
      stub(arg_t = Object.new).tag { :utf8 }
      stub(info = Object.new).argument_type { arg_t }
      val =
        GObject::Helper.signal_argument_to_gvalue(
          info, "foo")
      assert_instance_of GObject::Value, val
      assert_equal "foo", val.get_string
    end
  end

  describe "#cast_signal_argument" do
    describe "with info for an enum" do
      before do
        enuminfo = get_introspection_data 'GLib', 'DateMonth'
        stub(arg_t = Object.new).interface { enuminfo }
        stub(arg_t).tag { :interface }
        stub(@info = Object.new).argument_type { arg_t }
      end

      it "casts an integer to its enum symbol" do
        res = GObject::Helper.cast_signal_argument @info, 7
        assert_equal :july, res
      end
    end

    describe "with info for an interface" do
      before do
        ifaceinfo = get_introspection_data 'Regress', 'TestInterface'
        stub(arg_t = Object.new).interface { ifaceinfo }
        stub(arg_t).tag { :interface }
        stub(@info = Object.new).argument_type { arg_t }
      end

      it "casts the argument by calling #to_object on it" do
        mock(ptr = Object.new).to_object { "good-result" }
        res = GObject::Helper.cast_signal_argument @info, ptr
        res.must_equal "good-result"
      end
    end
  end

end

