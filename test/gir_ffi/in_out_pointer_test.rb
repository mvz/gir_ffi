# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::InOutPointer do
  describe '.new' do
    it 'wraps an existing pointer and a type' do
      ptr = GirFFI::AllocationHelper.safe_malloc(FFI.type_size(:int32))
      ptr.put_int32 0, 42
      instance = GirFFI::InOutPointer.new :gint32, ptr
      instance.to_value.must_equal 42
    end
  end

  describe 'in instance created with .for' do
    before do
      @result = GirFFI::InOutPointer.for :gint32
    end

    it 'holds a pointer to a null value' do
      assert_equal 0, @result.get_int32(0)
    end

    it 'is an instance of GirFFI::InOutPointer' do
      assert_instance_of GirFFI::InOutPointer, @result
    end
  end

  describe '.for' do
    it 'handles :gboolean' do
      result = GirFFI::InOutPointer.for :gboolean
      result.to_value.must_equal false
    end

    it 'handles :utf8' do
      result = GirFFI::InOutPointer.for :utf8
      result.to_value.must_be :null?
    end

    it 'handles GObject::Value' do
      result = GirFFI::InOutPointer.for GObject::Value
      type_size = FFI.type_size GObject::Value
      expected = "\x00" * type_size
      result.to_value.read_bytes(type_size).must_equal expected
    end
  end

  describe '#set_value' do
    it 'works setting the value to nil for GObject::Value' do
      pointer = GirFFI::InOutPointer.allocate_new GObject::Value
      pointer.set_value GObject::Value.from(3)
      pointer.set_value nil
      type_size = FFI.type_size GObject::Value
      expected = "\x00" * type_size
      pointer.to_value.read_bytes(type_size).must_equal expected
    end
  end

  describe '#to_value' do
    it 'returns the held value' do
      ptr = GirFFI::InOutPointer.allocate_new :gint32
      ptr.set_value 123
      assert_equal 123, ptr.to_value
    end

    describe 'for :gboolean values' do
      it 'works when the value is false' do
        ptr = GirFFI::InOutPointer.allocate_new :gboolean
        ptr.set_value false
        ptr.to_value.must_equal false
      end

      it 'works when the value is true' do
        ptr = GirFFI::InOutPointer.allocate_new :gboolean
        ptr.set_value true
        ptr.to_value.must_equal true
      end
    end

    describe 'for :utf8 values' do
      it 'returns a pointer to the held string value' do
        str_ptr = GirFFI::InPointer.from :utf8, 'Some value'
        ptr = GirFFI::InOutPointer.allocate_new :utf8
        ptr.set_value str_ptr
        assert_equal 'Some value', ptr.to_value.read_string
      end
    end

    describe 'for struct values' do
      it 'returns a pointer to the held value' do
        val = GObject::EnumValue.new
        val.value = 3
        ptr = GirFFI::InOutPointer.allocate_new GObject::EnumValue
        ptr.set_value val
        result = ptr.to_value
        GObject::EnumValue.wrap(result).value.must_equal 3
      end
    end
  end
end
