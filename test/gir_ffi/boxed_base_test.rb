# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::BoxedBase do
  describe 'wrap_copy' do
    it 'returns a wrapped copy with autorelease true' do
      original = GIMarshallingTests::BoxedStruct.new
      copy = GIMarshallingTests::BoxedStruct.wrap_copy(original.to_ptr)
      copy.to_ptr.wont_equal original.to_ptr
      copy.to_ptr.must_be :autorelease?
    end
  end

  describe 'copy_from' do
    it 'returns a copy with autorelease false' do
      original = GIMarshallingTests::BoxedStruct.new
      copy = GIMarshallingTests::BoxedStruct.copy_from(original)
      copy.to_ptr.wont_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
    end
  end
end
