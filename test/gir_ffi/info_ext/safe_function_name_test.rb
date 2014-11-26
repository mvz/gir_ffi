require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::SafeFunctionName do
  let(:klass) {
    Class.new do
      include GirFFI::InfoExt::SafeFunctionName
    end
  }
  let(:info) { klass.new }

  describe '#safe_name' do
    it 'keeps lower case names lower case' do
      mock(info).name { 'foo' }

      assert_equal 'foo', info.safe_name
    end

    it 'returns a non-empty string if name is empty' do
      mock(info).name { '' }

      assert_equal '_', info.safe_name
    end
  end
end
