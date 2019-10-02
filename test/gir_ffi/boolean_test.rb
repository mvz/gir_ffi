# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::Boolean do
  it 'has the same native size as an int' do
    _(FFI.type_size(GirFFI::Boolean)).must_equal FFI.type_size :int
  end

  describe '.from_native' do
    it 'converts 0 to false' do
      _(GirFFI::Boolean.from_native(0, 'whatever')).must_equal false
    end

    it 'converts 1 to true' do
      _(GirFFI::Boolean.from_native(1, 'whatever')).must_equal true
    end
  end

  describe '.to_native' do
    it 'converts false to 0' do
      _(GirFFI::Boolean.to_native(false, 'whatever')).must_equal 0
    end

    it 'converts true to 1' do
      _(GirFFI::Boolean.to_native(true, 'whatever')).must_equal 1
    end

    it 'converts nil to 0' do
      _(GirFFI::Boolean.to_native(nil, 'whatever')).must_equal 0
    end

    it 'converts truthy value to 1' do
      _(GirFFI::Boolean.to_native('i am truth!', 'whatever')).must_equal 1
    end
  end

  describe '.size' do
    it 'returns the correct type size' do
      _(GirFFI::Boolean.size).must_equal FFI.type_size :int
    end
  end
end
