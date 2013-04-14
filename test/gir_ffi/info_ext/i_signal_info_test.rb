require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ISignalInfo do
  describe "#cast_back_signal_arguments" do
    it "correctly casts back pointers for the test-with-static-scope-arg signal" do
      o = Regress::TestSubObj.new
      b = Regress::TestSimpleBoxedA.new
      ud = GirFFI::ArgHelper.object_to_inptr "Hello!"

      assert_equal "Hello!", GirFFI::ArgHelper::OBJECT_STORE[ud.address]

      sig = o.class.find_signal "test-with-static-scope-arg"

      gva = sig.cast_back_signal_arguments(o.to_ptr, b.to_ptr, ud)

      klasses = gva.map {|it| it.class}
      klasses.must_equal [ Regress::TestSubObj,
                           Regress::TestSimpleBoxedA,
                           String ]
      gva[2].must_equal "Hello!"
    end
  end

  describe "#signal_arguments_to_gvalue_array" do
    describe "the result of wrapping test-with-static-scope-arg" do
      setup do
        o = Regress::TestSubObj.new
        b = Regress::TestSimpleBoxedA.new
        sig = o.class.find_signal "test-with-static-scope-arg"

        @gva = sig.signal_arguments_to_gvalue_array(o, b)
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
end
