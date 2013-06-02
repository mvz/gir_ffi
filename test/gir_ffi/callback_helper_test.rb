require 'gir_ffi_test_helper'

describe GirFFI::CallbackHelper do
  describe ".store_callback" do
    it "stores the passed in proc in GirFFI::CallbackHelper::CALLBACKS" do
      GirFFI::CallbackHelper.store_callback "some-callback"
      GirFFI::CallbackHelper::CALLBACKS.last.must_equal "some-callback"
    end
  end
end
