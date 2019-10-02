# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::StructLikeBase do
  describe 'wrap_copy' do
    it 'returns a wrapped owned copy of structs' do
      original = GIMarshallingTests::SimpleStruct.new
      copy = GIMarshallingTests::SimpleStruct.wrap_copy(original.to_ptr)
      _(copy.to_ptr).wont_be :==, original.to_ptr
      _(copy.to_ptr).wont_be :autorelease?
      _(copy.struct).must_be :owned?
    end

    it 'returns a wrapped owned copy of unions' do
      original = GIMarshallingTests::Union.new
      copy = GIMarshallingTests::Union.wrap_copy(original.to_ptr)
      _(copy.to_ptr).wont_be :==, original.to_ptr
      _(copy.to_ptr).wont_be :autorelease?
      _(copy.struct).must_be :owned?
    end

    it 'returns a wrapped owned copy of boxed types' do
      original = GIMarshallingTests::BoxedStruct.new
      copy = GIMarshallingTests::BoxedStruct.wrap_copy(original.to_ptr)
      ptr = copy.to_ptr
      _(ptr).wont_be :==, original.to_ptr
      _(ptr).wont_be :autorelease? if ptr.respond_to? :autorelease
      _(copy.struct).must_be :owned?
    end

    it 'returns nil when passed nil' do
      _(GIMarshallingTests::SimpleStruct.wrap_copy(nil)).must_be_nil
    end
  end

  describe 'copy_from' do
    it 'returns an unowned copy of unions' do
      original = GIMarshallingTests::Union.new
      original.long_ = 42
      copy = GIMarshallingTests::Union.copy_from(original)
      _(copy.long_).must_equal 42
      _(copy.to_ptr).wont_be :==, original.to_ptr
      _(copy.to_ptr).wont_be :autorelease?
      _(copy.struct).wont_be :owned?
    end

    it 'returns an unowned copy of structs' do
      original = GIMarshallingTests::SimpleStruct.new
      copy = GIMarshallingTests::SimpleStruct.copy_from(original)
      _(copy.to_ptr).wont_be :==, original.to_ptr
      _(copy.to_ptr).wont_be :autorelease?
      _(copy.struct).wont_be :owned?
    end

    it 'returns nil when passed nil' do
      _(GIMarshallingTests::SimpleStruct.copy_from(nil)).must_be_nil
    end

    it 'converts its argument if that is possible' do
      _(GObject::Value.copy_from(4)).must_be_instance_of GObject::Value
    end
  end

  describe 'wrap_own' do
    it 'wraps and owns the supplied pointer for structs' do
      original = GIMarshallingTests::SimpleStruct.new
      original.struct.owned = false

      copy = GIMarshallingTests::SimpleStruct.wrap_own(original.to_ptr)
      _(copy.to_ptr).must_equal original.to_ptr
      _(copy.to_ptr).wont_be :autorelease?
      _(copy.struct).must_be :owned?
    end

    it 'wraps and owns the supplied pointer for unions' do
      original = GIMarshallingTests::Union.new
      original.struct.owned = false

      copy = GIMarshallingTests::Union.wrap_own(original.to_ptr)
      _(copy.to_ptr).must_equal original.to_ptr
      _(copy.to_ptr).wont_be :autorelease?
      _(copy.struct).must_be :owned?
    end

    it 'returns nil when passed nil' do
      _(GIMarshallingTests::SimpleStruct.wrap_own(nil)).must_be_nil
    end
  end

  describe '.native_type' do
    let(:type) { GIMarshallingTests::SimpleStruct.native_type }

    it 'is a struct by value' do
      _(type).must_be_instance_of FFI::StructByValue
    end

    it 'wraps the types nested struct class' do
      _(type.struct_class).must_equal GIMarshallingTests::SimpleStruct::Struct
    end
  end

  describe '.to_native' do
    it "returns the supplied value's struct" do
      object = GIMarshallingTests::SimpleStruct.new
      result = object.class.to_native(object, 'some-context')
      _(result).must_equal object.struct
    end
  end

  describe '.to_ffi_type' do
    it 'returns the class itself' do
      struct_class = GIMarshallingTests::SimpleStruct
      ffi_type = struct_class.to_ffi_type
      _(ffi_type).must_equal struct_class
    end
  end

  describe '.get_value_from_pointer' do
    let(:struct_class) { GIMarshallingTests::SimpleStruct }

    it 'returns just a pointer' do
      object = struct_class.new
      ptr = object.to_ptr
      result = struct_class.get_value_from_pointer(ptr, 0)
      _(result).must_be :==, ptr
    end

    it 'uses offset correctly' do
      struct1 = struct_class.new.tap { |it| it.long_ = 42 }
      struct2 = struct_class.new.tap { |it| it.long_ = 24 }
      array_ptr = GirFFI::InPointer.from_array(struct_class, [struct1, struct2])
      ptr = struct_class.get_value_from_pointer(array_ptr, struct_class.size)
      result = struct_class.wrap(ptr)
      _(result.long_).must_equal 24
    end
  end

  describe '.copy_value_to_pointer' do
    let(:struct_class) { GIMarshallingTests::SimpleStruct }
    let(:struct) { struct_class.new }

    it 'copies data correctly' do
      struct.long_ = 42
      target = FFI::MemoryPointer.new struct_class.size
      struct_class.copy_value_to_pointer(struct, target)
      result = struct_class.wrap(target)
      _(result.long_).must_equal 42
    end

    it 'uses offset correctly' do
      struct.long_ = 42
      target = FFI::MemoryPointer.new struct_class.size + 10
      struct_class.copy_value_to_pointer(struct, target, 10)
      result = struct_class.wrap(target + 10)
      _(result.long_).must_equal 42
    end
  end

  it 'adds its class methods to classes that include it' do
    struct_class = Class.new
    struct_class.send :include, GirFFI::StructLikeBase
    _(struct_class.singleton_class).must_include GirFFI::StructLikeBase::ClassMethods
  end
end
