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

  describe 'an instance created with .from' do
    before do
      @result = GirFFI::InOutPointer.from :gint32, 23
    end

    it 'holds a pointer to the given value' do
      assert_equal 23, @result.get_int32(0)
    end

    it 'is an instance of GirFFI::InOutPointer' do
      assert_instance_of GirFFI::InOutPointer, @result
    end
  end

  describe '.from' do
    it 'handles :gboolean false' do
      ptr = GirFFI::InOutPointer.from :gboolean, false
      ptr.read_int.must_equal 0
    end

    it 'handles :gboolean true' do
      ptr = GirFFI::InOutPointer.from :gboolean, true
      ptr.read_int.must_equal(1)
    end

    it 'handles :utf8 pointers' do
      str_ptr = GirFFI::InPointer.from :utf8, 'Hello'
      GirFFI::InOutPointer.from :utf8, str_ptr
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
      GirFFI::InOutPointer.for :gboolean
    end

    it 'handles :utf8' do
      GirFFI::InOutPointer.for :utf8
    end
  end

  describe '#to_value' do
    it 'returns the held value' do
      ptr = GirFFI::InOutPointer.from :gint32, 123
      assert_equal 123, ptr.to_value
    end

    describe 'for :gboolean values' do
      it 'works when the value is false' do
        ptr = GirFFI::InOutPointer.from :gboolean, false
        ptr.to_value.must_equal false
      end

      it 'works when the value is true' do
        ptr = GirFFI::InOutPointer.from :gboolean, true
        ptr.to_value.must_equal true
      end
    end

    describe 'for :utf8 values' do
      it 'returns a pointer to the held value' do
        str_ptr = GirFFI::InPointer.from :utf8, 'Some value'
        ptr = GirFFI::InOutPointer.from :utf8, str_ptr
        assert_equal 'Some value', ptr.to_value.read_string
      end
    end

    describe 'for struct values' do
      it 'returns a pointer to the held value' do
        val = GObject::EnumValue.new
        val.value = 3
        ptr = GirFFI::InOutPointer.from GObject::EnumValue, val
        result = ptr.to_value
        GObject::EnumValue.wrap(result).value.must_equal 3
      end
    end
  end
end
