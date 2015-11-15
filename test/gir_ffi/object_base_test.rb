require 'gir_ffi_test_helper'

describe GirFFI::ObjectBase do
  let(:derived_class) { Class.new GirFFI::ObjectBase }

  describe '.wrap' do
    it 'delegates conversion to the wrapped pointer' do
      expect(ptr = Object.new).to receive(:to_object).and_return 'good-result'
      derived_class.wrap(ptr).must_equal 'good-result'
    end
  end

  describe '.to_ffi_type' do
    it 'returns itself' do
      derived_class.to_ffi_type.must_equal derived_class
    end
  end
end
