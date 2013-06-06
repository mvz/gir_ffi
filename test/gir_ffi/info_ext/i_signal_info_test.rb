require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ISignalInfo do
  let(:testclass) { Class.new do
    include GirFFI::InfoExt::ISignalInfo
  end }
  let(:signal_info) { testclass.new }

  describe "#cast_back_signal_arguments" do
    # TODO: Move to integration tests
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
    # TODO: Move to integration tests
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

  describe "#itypeinfo_to_callback_ffitype" do
    describe "for an :interface argument" do
      before do
        @iface = Object.new
        stub(@info = Object.new).interface { @iface }
        stub(@info).tag { :interface }
        stub(@info).pointer? { false }
      end

      it "correctly maps a :union argument to :pointer" do
        stub(@iface).info_type { :union }

        result = signal_info.itypeinfo_to_callback_ffitype @info

        assert_equal :pointer, result
      end

      it "correctly maps a :flags argument to :int32" do
        stub(@iface).info_type { :flags }

        result = signal_info.itypeinfo_to_callback_ffitype @info

        assert_equal :int32, result
      end
    end
  end
end
