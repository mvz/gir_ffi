# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::StructLikeBase do
  describe 'wrap_copy' do
    it 'returns a wrapped owned copy of structs' do
      original = GIMarshallingTests::SimpleStruct.new
      copy = GIMarshallingTests::SimpleStruct.wrap_copy(original.to_ptr)
      copy.to_ptr.wont_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.must_be :owned?
    end

    it 'returns a wrapped owned copy of unions' do
      original = GIMarshallingTests::Union.new
      copy = GIMarshallingTests::Union.wrap_copy(original.to_ptr)
      copy.to_ptr.wont_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.must_be :owned?
    end
  end

  describe 'copy_from' do
    it 'returns an unowned copy of unions' do
      original = GIMarshallingTests::Union.new
      copy = GIMarshallingTests::Union.copy_from(original)
      copy.to_ptr.wont_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.wont_be :owned?
    end

    it 'returns an unowned copy of structs' do
      original = GIMarshallingTests::SimpleStruct.new
      copy = GIMarshallingTests::SimpleStruct.copy_from(original)
      copy.to_ptr.wont_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.wont_be :owned?
    end
  end

  describe 'wrap_own' do
    it 'wraps and owns the supplied value for structs' do
      original = GIMarshallingTests::SimpleStruct.new
      original.struct.owned = false

      copy = GIMarshallingTests::SimpleStruct.wrap_own(original.to_ptr)
      copy.to_ptr.must_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.must_be :owned?
    end

    it 'wraps and owns the supplied value for unions' do
      original = GIMarshallingTests::Union.new
      original.struct.owned = false

      copy = GIMarshallingTests::Union.wrap_own(original.to_ptr)
      copy.to_ptr.must_equal original.to_ptr
      copy.to_ptr.wont_be :autorelease?
      copy.struct.must_be :owned?
    end
  end
end
