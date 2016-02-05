# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GLib::DestroyNotify do
  describe '.default' do
    it 'removes the passed-in key from the callback store' do
      dummy_proc = 'some-callback'
      GirFFI::CallbackBase.store_callback dummy_proc
      user_data = GirFFI::InPointer.from_closure_data dummy_proc.object_id
      GLib::DestroyNotify.default.call user_data
      GirFFI::CallbackBase::CALLBACKS[dummy_proc.object_id].must_be_nil
    end
  end
end
