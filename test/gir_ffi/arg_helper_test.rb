# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::ArgHelper do
  describe '.cast_from_pointer' do
    it 'handles class types' do
      klass = Class.new
      expect(klass).to receive(:wrap).with(:pointer_value).and_return :wrapped_value
      GirFFI::ArgHelper.cast_from_pointer(klass, :pointer_value).must_equal :wrapped_value
    end

    describe 'for :gint8' do
      it 'handles negative :gint8' do
        ptr = FFI::Pointer.new(-127)
        GirFFI::ArgHelper.cast_from_pointer(:gint8, ptr).must_equal(-127)
      end

      it 'handles positive :gint8' do
        ptr = FFI::Pointer.new(128)
        GirFFI::ArgHelper.cast_from_pointer(:gint8, ptr).must_equal(128)
      end
    end

    it 'handles :guint32' do
      ptr = FFI::Pointer.new(0xffffffff)
      GirFFI::ArgHelper.cast_from_pointer(:guint32, ptr).must_equal(0xffffffff)
    end

    describe 'for :gint32' do
      it 'handles positive :gint32' do
        ptr = FFI::Pointer.new(1)
        GirFFI::ArgHelper.cast_from_pointer(:gint32, ptr).must_equal(1)
      end

      it 'handles negative :gint32' do
        ptr = FFI::Pointer.new(0xffffffff)
        GirFFI::ArgHelper.cast_from_pointer(:gint32, ptr).must_equal(-1)
      end

      it 'handles largest negative :gint32' do
        ptr = FFI::Pointer.new(0x80000000)
        GirFFI::ArgHelper.cast_from_pointer(:gint32, ptr).must_equal(-0x80000000)
      end

      it 'handles largest positive :gint32' do
        ptr = FFI::Pointer.new(0x7fffffff)
        GirFFI::ArgHelper.cast_from_pointer(:gint32, ptr).must_equal(0x7fffffff)
      end
    end

    it 'handles :utf8' do
      ptr = FFI::MemoryPointer.from_string 'foo'
      GirFFI::ArgHelper.cast_from_pointer(:utf8, ptr).must_equal 'foo'
    end

    it 'handles :filename' do
      ptr = FFI::MemoryPointer.from_string 'foo'
      GirFFI::ArgHelper.cast_from_pointer(:filename, ptr).must_equal 'foo'
    end

    it 'handles GHashTable' do
      hash = GLib::HashTable.from [:utf8, :gint32], { 'foo' => 1, 'bar' => 2 }
      ptr = hash.to_ptr
      result = GirFFI::ArgHelper.cast_from_pointer([:pointer, [:ghash, :utf8, :gint32]], ptr)
      result.to_hash.must_equal hash.to_hash
    end

    describe 'when passing a broken typespec' do
      it 'raises on unknown symbol' do
        ptr = FFI::Pointer.new(0xffffffff)
        exception = lambda { GirFFI::ArgHelper.cast_from_pointer(:foo, ptr) }.must_raise
        exception.message.must_equal "Don't know how to cast foo"
      end

      it 'raises on unexpected main type for complex type' do
        ptr = FFI::Pointer.new(0xffffffff)
        exception = lambda { GirFFI::ArgHelper.cast_from_pointer([:utf8], ptr) }.must_raise
        exception.message.must_equal "Don't know how to cast [:utf8]"
      end

      it 'raises on unexpected sub type for complex type' do
        ptr = FFI::Pointer.new(0xffffffff)
        exception = lambda { GirFFI::ArgHelper.cast_from_pointer([:pointer, :utf8], ptr) }.must_raise
        exception.message.must_equal "Don't know how to cast [:pointer, :utf8]"
      end

      it 'raises on unexpected container type for complex type' do
        ptr = FFI::Pointer.new(0xffffffff)
        exception = lambda { GirFFI::ArgHelper.cast_from_pointer([:pointer, [:gint32]], ptr) }.must_raise
        exception.message.must_equal "Don't know how to cast [:pointer, [:gint32]]"
      end
    end
  end

  describe '.store' do
    describe 'when called with nil' do
      it 'returns a null pointer' do
        GirFFI::ArgHelper.store(nil).must_be :null?
      end
    end

    describe 'when called with a string' do
      it 'stores the string in GirFFI::ArgHelper::OBJECT_STORE' do
        str = 'Foo'
        ptr = GirFFI::ArgHelper.store(str)
        result = GirFFI::ArgHelper::OBJECT_STORE.fetch(ptr)
        result.must_equal str
      end
    end
  end

  describe '.check_fixed_array_size' do
    it 'passes if array has the correct size' do
      GirFFI::ArgHelper.check_fixed_array_size(3, [1, 2, 3], 'foo')
      pass
    end

    it 'raises if array does not have the correct size' do
      result = lambda do
        GirFFI::ArgHelper.check_fixed_array_size(3, [1, 2], 'foo')
      end.must_raise ArgumentError
      result.message.must_equal 'foo should have size 3'
    end
  end

  describe '.check_error' do
    it 'does nothing if there is no error' do
      err_ptr = double('err_ptr', read_pointer: nil)
      GirFFI::ArgHelper.check_error err_ptr
      pass
    end

    it 'raises an exception if there is an error' do
      err = GLib::Error.new
      err_ptr = double('err_ptr', read_pointer: err.to_ptr)
      lambda { GirFFI::ArgHelper.check_error err_ptr }.must_raise GirFFI::GLibError
    end
  end
end
