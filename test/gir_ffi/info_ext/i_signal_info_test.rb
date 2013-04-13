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
end

