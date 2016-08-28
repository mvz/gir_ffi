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

    it 'returns nil when passed nil' do
      GIMarshallingTests::SimpleStruct.wrap_copy(nil).must_be_nil
    end
  end

  describe 'copy_from' do
    it 'returns an unowned copy of unions' do
      original = GIMarshallingTests::Union.new
      original.long_ = 42
      copy = GIMarshallingTests::Union.copy_from(original)
      copy.long_.must_equal 42
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

    it 'returns nil when passed nil' do
      GIMarshallingTests::SimpleStruct.copy_from(nil).must_be_nil
    end

    it 'converts its argument if that is possible' do
      GObject::Value.copy_from(4).must_be_instance_of GObject::Value
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

    it 'returns nil when passed nil' do
      GIMarshallingTests::SimpleStruct.wrap_own(nil).must_be_nil
    end
  end

  describe '.native_type' do
    let(:type) { GIMarshallingTests::SimpleStruct.native_type }

    it 'is a struct by value' do
      type.must_be_instance_of FFI::StructByValue
    end

    it 'wraps the types nested struct class' do
      type.struct_class.must_equal GIMarshallingTests::SimpleStruct::Struct
    end
  end

  describe '.to_native' do
    it "returns the supplied value's struct" do
      object = GIMarshallingTests::SimpleStruct.new
      result = object.class.to_native(object, 'some-context')
      result.must_equal object.struct
    end
  end

  describe '.to_ffi_type' do
    it 'returns the class itself' do
      klass = GIMarshallingTests::SimpleStruct
      ffi_type = klass.to_ffi_type
      ffi_type.must_equal klass
    end
  end

  describe '.get_value_from_pointer' do
    let(:klass) { GIMarshallingTests::SimpleStruct }

    it 'returns just a pointer' do
      object = klass.new
      ptr = object.to_ptr
      klass.get_value_from_pointer(ptr, 0).must_equal ptr
    end

    it 'uses offset correctly' do
      struct1 = klass.new.tap { |it| it.long_ = 42 }
      struct2 = klass.new.tap { |it| it.long_ = 24 }
      array_ptr = GirFFI::InPointer.from_array(klass, [struct1, struct2])
      ptr = klass.get_value_from_pointer(array_ptr, klass.size)
      result = klass.wrap(ptr)
      result.long_.must_equal 24
    end
  end

  describe '.copy_value_to_pointer' do
    let(:klass) { GIMarshallingTests::SimpleStruct }
    let(:struct) { klass.new }

    it 'copies data correctly' do
      struct.long_ = 42
      target = FFI::MemoryPointer.new klass.size
      klass.copy_value_to_pointer(struct, target)
      result = klass.wrap(target)
      result.long_.must_equal 42
    end

    it 'uses offset correctly' do
      struct.long_ = 42
      target = FFI::MemoryPointer.new klass.size + 10
      klass.copy_value_to_pointer(struct, target, 10)
      result = klass.wrap(target + 10)
      result.long_.must_equal 42
    end
  end

  it 'adds its class methods to classes that include it' do
    klass = Class.new
    klass.include GirFFI::StructLikeBase
    klass.singleton_class.must_include GirFFI::StructLikeBase::ClassMethods
  end
end
