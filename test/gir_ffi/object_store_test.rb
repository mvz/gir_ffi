# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::ObjectStore do
  let(:store) { GirFFI::ObjectStore.new }

  describe '#store' do
    it 'returns a non-null pointer when storing objects' do
      obj = Object.new
      ptr = store.store obj
      ptr.wont_be :null?
    end

    it 'returns a null pointer when storing nil' do
      ptr = store.store nil
      ptr.must_be :null?
    end
  end

  describe '#fetch' do
    it 'returns the stored object when passed the key pointer' do
      obj = Object.new
      ptr = store.store obj
      result = store.fetch ptr
      result.must_equal obj
    end

    it 'returns the nil object when passed a null pointer' do
      ptr = FFI::Pointer.new(0)
      result = store.fetch ptr
      result.must_be_nil
    end

    it 'returns the pointer itself when passed an unknown pointer' do
      ptr = FFI::Pointer.new(42)
      result = store.fetch ptr
      result.must_equal ptr
    end
  end
end
