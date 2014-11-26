require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::SafeConstantName do
  let(:klass) {
    Class.new do
      include GirFFI::InfoExt::SafeConstantName
    end
  }
  let(:info) { klass.new }

  describe '#safe_name' do
    it 'makes names starting with an underscore safe' do
      mock(info).name { '_foo' }

      assert_equal 'Private___foo', info.safe_name
    end

    it 'makes names with dashes safe' do
      mock(info).name { 'this-could-be-a-signal-name' }

      info.safe_name.must_equal 'This_could_be_a_signal_name'
    end
  end
end
