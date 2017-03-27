# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::InOutPointer do
  describe '.new' do
    it 'wraps an existing pointer and a type' do
      ptr = FFI::MemoryPointer.new(:int32)
      ptr.put_int32 0, 42
      instance = GirFFI::InOutPointer.new :gint32, ptr
      instance.to_value.must_equal 42
    end
  end

  describe '#to_value' do
    it 'returns the held value' do
      ptr = GirFFI::InOutPointer.allocate_new :gint32
      ptr.put_int32 0, 123
      assert_equal 123, ptr.to_value
    end

    describe 'for :gboolean values' do
      it 'works when the value is false' do
        ptr = GirFFI::InOutPointer.allocate_new :gboolean
        ptr.put_int 0, 0
        ptr.to_value.must_equal false
      end

      it 'works when the value is true' do
        ptr = GirFFI::InOutPointer.allocate_new :gboolean
        ptr.put_int 0, 1
        ptr.to_value.must_equal true
      end
    end

    describe 'for :utf8 values' do
      it 'returns a pointer to the held string value' do
        str_ptr = GirFFI::InPointer.from_utf8 'Some value'
        ptr = GirFFI::InOutPointer.allocate_new :utf8
        ptr.put_pointer 0, str_ptr
        assert_equal 'Some value', ptr.to_value.read_string
      end
    end

    describe 'for struct values' do
      it 'returns a pointer to the held value' do
        val = GObject::EnumValue.new
        val.value = 3
        ptr = GirFFI::InOutPointer.allocate_new GObject::EnumValue
        GObject::EnumValue.copy_value_to_pointer val, ptr
        result = ptr.to_value
        GObject::EnumValue.wrap(result).value.must_equal 3
      end
    end
  end
end
