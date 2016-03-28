# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::UnionBase do
  describe 'new' do
    it 'creates an instance with an owned struct' do
      instance = GIMarshallingTests::Union.new
      instance.struct.must_be :owned?
    end

    it 'ensures the wrapped pointer is not autoreleased' do
      instance = GIMarshallingTests::Union.new
      instance.to_ptr.wont_be :autorelease?
    end
  end

  describe 'wrap_copy' do
    it 'returns a wrapped owned copy' do
      original = GIMarshallingTests::Union.new
      copy = GIMarshallingTests::Union.wrap_copy(original.to_ptr)
      copy.to_ptr.wont_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.must_be :owned?
    end
  end

  describe 'copy_from' do
    it 'returns an unowned copy' do
      original = GIMarshallingTests::Union.new
      copy = GIMarshallingTests::Union.copy_from(original)
      copy.to_ptr.wont_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.wont_be :owned?
    end
  end
end
