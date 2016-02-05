# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GLib::PtrArray do
  it 'knows its element type' do
    arr = GLib::PtrArray.new :utf8
    assert_equal :utf8, arr.element_type
  end

  describe '::add' do
    it 'correctly takes the type into account' do
      arr = GLib::PtrArray.new :utf8
      str = 'test'
      GLib::PtrArray.add arr, str

      assert_equal str, arr.pdata.read_pointer.read_string
    end
  end

  describe '#each' do
    it 'works normally' do
      arr = GLib::PtrArray.new :utf8

      GLib::PtrArray.add arr, 'test1'
      GLib::PtrArray.add arr, 'test2'
      GLib::PtrArray.add arr, 'test3'

      a = []
      arr.each { |v| a << v }

      assert_equal %w(test1 test2 test3), a
    end

    it 'works when exiting the loop prematurely' do
      arr = GLib::PtrArray.new :utf8

      GLib::PtrArray.add arr, 'test1'
      GLib::PtrArray.add arr, 'test2'
      GLib::PtrArray.add arr, 'test3'

      a = []
      arr.each do |v|
        a << v
        break if v == 'test2'
      end

      assert_equal %w(test1 test2), a
    end
  end

  it 'includes Enumerable' do
    GLib::PtrArray.must_include Enumerable
  end

  it 'has a working #to_a method' do
    arr = GLib::PtrArray.new :utf8

    GLib::PtrArray.add arr, 'test1'
    GLib::PtrArray.add arr, 'test2'
    GLib::PtrArray.add arr, 'test3'

    assert_equal %w(test1 test2 test3), arr.to_a
  end

  it 'has #add as an instance method too' do
    arr = GLib::PtrArray.new :utf8
    arr.add 'test1'
    assert_equal ['test1'], arr.to_a
  end

  describe '#==' do
    it 'returns true when comparing to an array with the same elements' do
      arr = GLib::PtrArray.from :utf8, %w(1 2 3)

      arr.must_be :==, %w(1 2 3)
    end

    it 'returns false when comparing to an array with different elements' do
      arr = GLib::PtrArray.from :utf8, %w(1 2 3)

      arr.wont_be :==, %w(1 2)
    end

    it 'returns true when comparing to a GPtrArray with the same elements' do
      arr = GLib::PtrArray.from :utf8, %w(1 2 3)
      other = GLib::PtrArray.from :utf8, %w(1 2 3)

      arr.must_be :==, other
    end

    it 'returns false when comparing to a GPtrArray with different elements' do
      arr = GLib::PtrArray.from :utf8, %w(1 2 3)
      other = GLib::PtrArray.from :utf8, %w(1 2)

      arr.wont_be :==, other
    end
  end

  describe '#index' do
    it 'returns the correct element' do
      arr = GLib::PtrArray.from :utf8, %w(1 2 3)
      arr.index(1).must_equal '2'
    end

    it 'raises an error if the index is out of bounds' do
      arr = GLib::PtrArray.from :utf8, %w(1 2 3)
      proc { arr.index(16) }.must_raise IndexError
      proc { arr.index(-1) }.must_raise IndexError
    end
  end
end
