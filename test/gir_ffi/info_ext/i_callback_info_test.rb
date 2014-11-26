require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ICallbackInfo do
  let(:klass) {
    Class.new do
      include GirFFI::InfoExt::ICallbackInfo
    end
  }
  let(:callback_info) { klass.new }

  describe '#return_ffi_type' do
    it 'returns the callback ffi type of the return type' do
      stub(return_type_info = Object.new).to_callback_ffitype { :some_type }
      stub(callback_info).return_type { return_type_info }

      callback_info.return_ffi_type.must_equal :some_type
    end
  end
end
