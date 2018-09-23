# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :Regress

describe GirFFI::EnumBase do
  describe '.wrap' do
    it 'converts an integer to a symbol if possible' do
      Regress::TestEnum.wrap(1).must_equal :value2
    end

    it 'passes an integer if it cannot be converted' do
      Regress::TestEnum.wrap(32).must_equal 32
    end

    it 'passes a known symbol untouched' do
      Regress::TestEnum.wrap(:value1).must_equal :value1
    end

    it 'passes an unknown symbol untouched' do
      Regress::TestEnum.wrap(:foo).must_equal :foo
    end
  end
end
