# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::ArgHelper do
  describe '.cast_from_pointer' do
    it 'handles class types' do
      klass = Class.new
      expect(klass).to receive(:wrap).with(:pointer_value).and_return :wrapped_value
      GirFFI::ArgHelper.cast_from_pointer(klass, :pointer_value).must_equal :wrapped_value
    end

    it 'handles negative :gint8' do
      ptr = FFI::Pointer.new(-127)
      GirFFI::ArgHelper.cast_from_pointer(:gint8, ptr).must_equal(-127)
    end

    it 'handles positive :gint8' do
      ptr = FFI::Pointer.new(128)
      GirFFI::ArgHelper.cast_from_pointer(:gint8, ptr).must_equal(128)
    end

    it 'handles :guint32' do
      ptr = FFI::Pointer.new(0xffffffff)
      GirFFI::ArgHelper.cast_from_pointer(:guint32, ptr).must_equal(0xffffffff)
    end
  end
end
