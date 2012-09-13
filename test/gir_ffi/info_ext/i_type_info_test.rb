require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ITypeInfo do
  let(:testclass) { Class.new do
    include GirFFI::InfoExt::ITypeInfo
  end }

  describe "#layout_specification_type" do
    it "returns an array with elements subtype and size for type :array" do
      mock(subtype = Object.new).layout_specification_type { :foo }

      type = testclass.new
      mock(type).array_fixed_size { 2 }
      mock(type).param_type(0) { subtype }

      mock(GirFFI::Builder).itypeinfo_to_ffitype(type) { :array }

      result = type.layout_specification_type

      assert_equal [:foo, 2], result
    end
  end

  describe "#subtype_tag" do
    it "returns :gpointer if the param_type is a pointer with tag :void" do
      type_info = testclass.new

      stub(subtype0 = Object.new).tag { :void }
      stub(subtype0).pointer? { true }

      mock(type_info).param_type(0) { subtype0 }

      assert_equal :gpointer, type_info.subtype_tag(0)
    end
  end

  describe "#element_type" do
    it "returns the element type for lists" do
      type_info = testclass.new
      mock(elm_type = Object.new).tag { :foo }

      mock(type_info).tag {:glist}
      mock(type_info).param_type(0) { elm_type }

      result = type_info.element_type
      result.must_equal :foo
    end

    it "returns the key and value types for ghashes" do
      type_info = testclass.new
      mock(key_type = Object.new).tag { :foo }
      mock(val_type = Object.new).tag { :bar }

      mock(type_info).tag {:ghash}
      mock(type_info).param_type(0) { key_type }
      mock(type_info).param_type(1) { val_type }

      result = type_info.element_type
      result.must_equal [:foo, :bar]
    end

    it "returns nil for other types" do
      type_info = testclass.new

      mock(type_info).tag {:foo}

      result = type_info.element_type
      result.must_be_nil
    end
  end
end
