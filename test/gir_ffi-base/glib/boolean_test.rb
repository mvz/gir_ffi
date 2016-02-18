# frozen_string_literal: true
require 'base_test_helper'

describe GLib::Boolean do
  it 'has the same native size as an int' do
    FFI.type_size(GLib::Boolean).must_equal FFI.type_size :int
  end

  describe '.from_native' do
    it 'converts 0 to false' do
      GLib::Boolean.from_native(0, 'whatever').must_equal false
    end

    it 'converts 1 to true' do
      GLib::Boolean.from_native(1, 'whatever').must_equal true
    end
  end

  describe '.to_native' do
    it 'converts false to 0' do
      GLib::Boolean.to_native(false, 'whatever').must_equal 0
    end

    it 'converts true to 1' do
      GLib::Boolean.to_native(true, 'whatever').must_equal 1
    end
  end

  describe '.size' do
    it 'returns the correct type size' do
      GLib::Boolean.size.must_equal FFI.type_size :int
    end
  end
end
