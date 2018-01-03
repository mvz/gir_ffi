# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::SafeConstantName do
  let(:info_class) do
    Class.new do
      include GirFFI::InfoExt::SafeConstantName
    end
  end
  let(:info) { info_class.new }

  describe '#safe_name' do
    it 'makes names starting with an underscore safe' do
      expect(info).to receive(:name).and_return '_foo'

      assert_equal 'Private___foo', info.safe_name
    end

    it 'makes names with dashes safe' do
      expect(info).to receive(:name).and_return 'this-could-be-a-signal-name'

      info.safe_name.must_equal 'This_could_be_a_signal_name'
    end
  end
end
