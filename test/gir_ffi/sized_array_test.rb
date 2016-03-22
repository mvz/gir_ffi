# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::SizedArray do
  describe '::wrap' do
    it 'takes a type, size and pointer and returns a GirFFI::SizedArray wrapping them' do
      expect(ptr = Object.new).to receive(:null?).and_return false
      sarr = GirFFI::SizedArray.wrap :gint32, 3, ptr
      assert_instance_of GirFFI::SizedArray, sarr
      assert_equal ptr, sarr.to_ptr
      assert_equal 3, sarr.size
      assert_equal :gint32, sarr.element_type
    end

    it 'returns nil if the wrapped pointer is null' do
      expect(ptr = Object.new).to receive(:null?).and_return true
      sarr = GirFFI::SizedArray.wrap :gint32, 3, ptr
      sarr.must_be_nil
    end
  end

  describe '#each' do
    it 'yields each element' do
      ary = %w(one two three)
      ptrs = ary.map { |a| FFI::MemoryPointer.from_string(a) }
      ptrs << nil
      block = FFI::MemoryPointer.new(:pointer, ptrs.length)
      block.write_array_of_pointer ptrs

      sarr = GirFFI::SizedArray.new :utf8, 3, block
      arr = []
      sarr.each do |str|
        arr << str
      end
      assert_equal %w(one two three), arr
    end
  end

  describe '::from' do
    describe 'from a Ruby array' do
      it 'creates a GirFFI::SizedArray with the same elements' do
        arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
        arr.must_be_instance_of GirFFI::SizedArray
        assert_equal [3, 2, 1], arr.to_a
      end

      it 'raises an error if the array has the wrong number of elements' do
        proc { GirFFI::SizedArray.from :gint32, 4, [3, 2, 1] }.must_raise ArgumentError
      end

      it "uses the array's size if passed -1 as the size" do
        arr = GirFFI::SizedArray.from :gint32, -1, [3, 2, 1]
        arr.size.must_equal 3
      end
    end

    describe 'from a GirFFI::SizedArray' do
      it 'return its argument' do
        arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
        arr2 = GirFFI::SizedArray.from :gint32, 3, arr
        assert_equal arr, arr2
      end

      it 'raises an error if the argument has the wrong number of elements' do
        arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
        proc { GirFFI::SizedArray.from :gint32, 4, arr }.must_raise ArgumentError
      end
    end

    it 'returns nil when passed nil' do
      arr = GirFFI::SizedArray.from :gint32, 0, nil
      arr.must_be_nil
    end

    it 'wraps its argument if given a pointer' do
      arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
      arr2 = GirFFI::SizedArray.from :gint32, 3, arr.to_ptr
      assert_instance_of GirFFI::SizedArray, arr2
      refute arr2.equal? arr
      arr2.to_ptr.must_equal arr.to_ptr
    end
  end

  describe '.copy_from' do
    describe 'from a Ruby array' do
      it 'creates an unowned GirFFI::SizedArray with the same elements' do
        arr = GirFFI::SizedArray.copy_from :gint32, 3, [3, 2, 1]
        arr.must_be_instance_of GirFFI::SizedArray
        assert_equal [3, 2, 1], arr.to_a
        arr.to_ptr.wont_be :autorelease?
      end

      it 'creates unowned copies of struct pointer elements' do
        struct = GIMarshallingTests::BoxedStruct.new
        struct.long_ = 2342
        arr = GirFFI::SizedArray.copy_from([:pointer, GIMarshallingTests::BoxedStruct],
                                           1,
                                           [struct])
        arr.must_be_instance_of GirFFI::SizedArray
        arr.to_ptr.wont_be :autorelease?

        struct_copy = arr.first
        struct_copy.long_.must_equal struct.long_
        struct_copy.to_ptr.wont_equal struct.to_ptr
        struct_copy.to_ptr.wont_be :autorelease?
      end

      it 'increases the ref count of object pointer elements' do
        obj = GIMarshallingTests::Object.new 42
        arr = GirFFI::SizedArray.copy_from([:pointer, GIMarshallingTests::Object],
                                           -1,
                                           [obj, nil])
        arr.must_be_instance_of GirFFI::SizedArray
        arr.to_ptr.wont_be :autorelease?

        arr.to_a.must_equal [obj, nil]
        obj.ref_count.must_equal 2
      end
    end

    describe 'from a GirFFI::SizedArray' do
      it 'return an unowned copy of its argument' do
        arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
        arr2 = GirFFI::SizedArray.copy_from :gint32, 3, arr
        arr.to_ptr.wont_equal arr2.to_ptr
        arr2.to_a.must_equal [3, 2, 1]
        arr2.to_ptr.wont_be :autorelease?
      end
    end

    it 'returns nil when passed nil' do
      arr = GirFFI::SizedArray.copy_from :gint32, 0, nil
      arr.must_be_nil
    end

    it 'creates an unowned copy of its argument if given a pointer' do
      arr = GirFFI::SizedArray.from :gint32, 3, [3, 2, 1]
      arr2 = GirFFI::SizedArray.copy_from :gint32, 3, arr.to_ptr
      assert_instance_of GirFFI::SizedArray, arr2
      arr2.to_ptr.wont_equal arr.to_ptr
      arr2.to_ptr.wont_be :autorelease?
      arr2.to_a.must_equal [3, 2, 1]
    end
  end

  describe '#==' do
    it 'returns true when comparing to an array with the same elements' do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]

      sized.must_be :==, [1, 2, 3]
    end

    it 'returns false when comparing to an array with different elements' do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]

      sized.wont_be :==, [1, 2]
    end

    it 'returns true when comparing to a sized array with the same elements' do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]
      other = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]

      sized.must_be :==, other
    end

    it 'returns false when comparing to a sized array with different elements' do
      sized = GirFFI::SizedArray.from :int32, 3, [1, 2, 3]
      other = GirFFI::SizedArray.from :int32, 2, [1, 2]

      sized.wont_be :==, other
    end
  end

  it 'includes Enumerable' do
    GirFFI::SizedArray.must_include Enumerable
  end
end
