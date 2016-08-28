# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::BoxedBase do
  describe 'initialize' do
    it 'sets up the held struct pointer' do
      value = GObject::Value.new
      value.to_ptr.wont_be_nil
    end
  end

  describe 'copy_from' do
    it 'returns a copy with owned false' do
      original = GIMarshallingTests::BoxedStruct.new
      copy = GIMarshallingTests::BoxedStruct.copy_from(original)
      copy.to_ptr.wont_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.wont_be :owned?
    end
  end

  describe 'wrap_own' do
    it 'wraps and owns the supplied pointer' do
      original = GIMarshallingTests::BoxedStruct.new
      copy = GIMarshallingTests::BoxedStruct.wrap_own(original.to_ptr)
      copy.to_ptr.must_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.must_be :owned?
    end
  end
end
