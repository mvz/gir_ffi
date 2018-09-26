# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::Builders::EnumBuilder do
  describe '#build_class' do
    let(:info) { get_introspection_data 'Regress', 'TestEnum' }
    let(:builder) { GirFFI::Builders::EnumBuilder.new info }

    it 'makes the created type know its proper name' do
      enum = builder.build_class
      enum.inspect.must_equal 'Regress::TestEnum'
    end

    it 'adds constants for the values' do
      enum = builder.build_class
      enum::VALUE1.must_equal enum[:value1]
      enum::VALUE2.must_equal enum[:value2]
      enum::VALUE3.must_equal enum[:value3]
      enum::VALUE4.must_equal enum[:value4]
    end
  end
end
