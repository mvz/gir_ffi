require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ISignalInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::ICallableInfo
    include GirFFI::InfoExt::ISignalInfo
  end }
  let(:signal_info) { klass.new }

  describe "#cast_back_signal_arguments" do
    # TODO: Move to integration tests
    it "correctly casts back pointers for the test-with-static-scope-arg signal" do
      o = Regress::TestSubObj.new
      b = Regress::TestSimpleBoxedA.new
      ud = GirFFI::InPointer.from_object "Hello!"

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

      it "is a GObject::ValueArray" do
        assert_instance_of GObject::ValueArray, @gva
      end

      it "contains two values" do
        assert_equal 2, @gva.n_values
      end

      it "has a first value with GType for TestSubObj" do
        assert_equal Regress::TestSubObj.get_gtype, (@gva.get_nth 0).current_gtype
      end

      it "has a second value with GType for TestSimpleBoxedA" do
        assert_equal Regress::TestSimpleBoxedA.get_gtype, (@gva.get_nth 1).current_gtype
      end
    end
  end

  describe "#return_ffi_type" do
    # FIXME: This is needed because callbacks are limited in the accepted
    # types. This should be fixed in FFI.
    it "returns :bool for the :gboolean type" do
      stub(return_type_info = Object.new).to_ffitype { GLib::Boolean }
      stub(signal_info).return_type { return_type_info }

      signal_info.return_ffi_type.must_equal :bool
    end
  end
end
