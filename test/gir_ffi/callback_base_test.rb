require 'gir_ffi_test_helper'

describe GirFFI::CallbackBase do
  describe ".store_callback" do
    it "stores the passed in proc in CALLBACKS" do
      GirFFI::CallbackBase.store_callback "some-callback"
      GirFFI::CallbackBase::CALLBACKS.last.must_equal "some-callback"
    end
  end
end

