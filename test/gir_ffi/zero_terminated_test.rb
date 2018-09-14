# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::ZeroTerminated do
  describe '.from' do
    let(:result) { GirFFI::ZeroTerminated.from :int32, [1, 2, 3] }

    it 'converts the passed array into a zero-terminated c array' do
      ptr = result.to_ptr
      ptr.read_array_of_int32(4).must_equal [1, 2, 3, 0]
    end

    it 'returns a GirFFI::ZeroTerminated object' do
      result.must_be_instance_of GirFFI::ZeroTerminated
    end

    it 'works for Regress::TestEnum from numbers' do
      GirFFI.setup :Regress
      enum_arr = GirFFI::ZeroTerminated.from Regress::TestEnum, [1, -1, 48]
      ptr = enum_arr.to_ptr
      ptr.read_array_of_int32(4).must_equal [1, -1, 48, 0]
    end

    it 'works for Regress::TestEnum from symbols' do
      GirFFI.setup :Regress
      enum_arr = GirFFI::ZeroTerminated.from Regress::TestEnum, [:value2, :value3, :value4]
      ptr = enum_arr.to_ptr
      ptr.read_array_of_int32(4).must_equal [1, -1, 48, 0]
    end
  end

  describe '.wrap' do
    it 'wraps the given type and pointer' do
      ptr = GirFFI::InPointer.from_array :int32, [1, 2, 3, 0]
      zt = GirFFI::ZeroTerminated.wrap :foo, ptr
      zt.element_type.must_equal :foo
      zt.to_ptr.must_equal ptr
    end
  end

  describe '#each' do
    it 'yields each element' do
      zt = GirFFI::ZeroTerminated.from :int32, [1, 2, 3]
      arr = []
      zt.each do |int|
        arr << int
      end
      arr.must_equal [1, 2, 3]
    end

    it 'yields zero times for a ZeroTerminated wrapping a null pointer' do
      zt = GirFFI::ZeroTerminated.wrap :int32, FFI::Pointer.new(0)
      zt.each do |_str|
        flunk
      end
    end

    it 'works for :int8' do
      zt = GirFFI::ZeroTerminated.from :int8, [1, 2, 3]
      arr = []
      zt.each do |int|
        arr << int
      end
      arr.must_equal [1, 2, 3]
    end
  end

  describe '#==' do
    it 'returns true when comparing to an array with the same elements' do
      zero_terminated = GirFFI::ZeroTerminated.from :int32, [1, 2, 3]

      (zero_terminated == [1, 2, 3]).must_equal true
    end

    it 'returns false when comparing to an array with different elements' do
      zero_terminated = GirFFI::ZeroTerminated.from :int32, [1, 2, 3]

      (zero_terminated == [1, 2]).must_equal false
    end

    it 'returns true when comparing to a zero-terminated array with the same elements' do
      zero_terminated = GirFFI::ZeroTerminated.from :int32, [1, 2, 3]
      other = GirFFI::ZeroTerminated.from :int32, [1, 2, 3]

      (zero_terminated == other).must_equal true
    end

    it 'returns false when comparing to a zero-terminated array with different elements' do
      zero_terminated = GirFFI::ZeroTerminated.from :int32, [1, 2, 3]
      other = GirFFI::ZeroTerminated.from :int32, [1, 2]

      (zero_terminated == other).must_equal false
    end
  end

  it 'includes Enumerable' do
    GirFFI::ZeroTerminated.must_include Enumerable
  end

  describe '#to_a' do
    it 'works for Regress::TestEnum' do
      GirFFI.setup :Regress
      enum_arr = GirFFI::ZeroTerminated.from Regress::TestEnum, [1, 48, -1]
      enum_arr.to_a.must_equal [:value2, :value4, :value3]
    end
  end
end
