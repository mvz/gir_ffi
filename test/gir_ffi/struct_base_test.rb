# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::StructBase do
  it 'inherits from StructLikeBase' do
    GirFFI::StructBase.must_include GirFFI::StructLikeBase
  end

  describe 'new' do
    it 'creates an instance with an owned struct' do
      instance = GIMarshallingTests::SimpleStruct.new
      instance.struct.must_be :owned?
    end

    it 'ensures the wrapped pointer is not autoreleased' do
      instance = GIMarshallingTests::SimpleStruct.new
      instance.to_ptr.wont_be :autorelease?
    end
  end

  describe 'wrap_own' do
    it 'wraps and owns the supplied value' do
      original = GIMarshallingTests::SimpleStruct.new
      original.struct.owned = false

      copy = GIMarshallingTests::SimpleStruct.wrap_own(original.to_ptr)
      copy.to_ptr.must_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.must_be :owned?
    end
  end
end
