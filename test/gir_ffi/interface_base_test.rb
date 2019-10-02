# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::InterfaceBase do
  let(:interface) { Module.new { extend GirFFI::InterfaceBase } }

  describe '#wrap' do
    it 'delegates conversion to the wrapped pointer' do
      expect(ptr = Object.new).to receive(:to_object).and_return 'good-result'
      _(interface.wrap(ptr)).must_equal 'good-result'
    end
  end

  describe '.to_ffi_type' do
    it 'returns :pointer' do
      _(interface.to_ffi_type).must_equal :pointer
    end
  end
end
