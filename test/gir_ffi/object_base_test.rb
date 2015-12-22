require 'gir_ffi_test_helper'

GirFFI.setup :Regress

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

  describe '.object_class' do
    it 'returns an object of the class struct type' do
      Regress::TestObj.object_class.must_be_instance_of Regress::TestObjClass
    end

    it 'caches its result' do
      first = Regress::TestObj.object_class
      second = Regress::TestObj.object_class
      second.must_be :eql?, first
    end
  end
end
