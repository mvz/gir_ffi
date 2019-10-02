# frozen_string_literal: true

require 'gir_ffi_test_helper'
require 'gir_ffi/receiver_argument_info'

describe GirFFI::ReceiverArgumentInfo do
  let(:dummy_type) { 'foo' }
  let(:instance) { GirFFI::ReceiverArgumentInfo.new dummy_type }

  describe '#argument_type' do
    it 'returns the argument type' do
      _(instance.argument_type).must_equal dummy_type
    end
  end

  describe '#direction' do
    it 'returns the correct value' do
      _(instance.direction).must_equal :in
    end
  end

  describe '#ownership_transfer' do
    it 'returns the correct value' do
      _(instance.ownership_transfer).must_equal :everything
    end
  end

  describe '#name' do
    it 'returns the correct value' do
      _(instance.name).must_equal '_instance'
    end
  end
end
