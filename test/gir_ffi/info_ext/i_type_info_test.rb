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

    it "returns :gpointer if the element type is a pointer with tag :void" do
      type_info = testclass.new

      stub(elm_type = Object.new).tag { :void }
      stub(elm_type).pointer? { true }

      mock(type_info).tag {:glist}
      mock(type_info).param_type(0) { elm_type }

      assert_equal :gpointer, type_info.element_type
    end
  end

  describe "#type_specification" do
    describe "for a simple type" do
      it "returns the type tag" do
	type_info = testclass.new
	stub(type_info).tag { :uint32 }
	type_info.type_specification.must_equal ":uint32"
      end
    end

    describe "for a zero-terminated utf8 array" do
      it "returns the pair [:strv, :utf8]" do
	type_info = testclass.new
	mock(type_info).tag { :array }
	stub(type_info).element_type { :utf8 }
	stub(type_info).zero_terminated? { true }
	stub(type_info).array_type { :c }
	type_info.type_specification.must_equal "[:strv, :utf8]"
      end
    end

    describe "for a zero-terminated array" do
      it "returns the pair [:zero_terminated, element_type]" do
	type_info = testclass.new
	mock(type_info).tag { :array }
	stub(type_info).element_type { :foo }
	stub(type_info).zero_terminated? { true }
	stub(type_info).array_type { :c }
	type_info.type_specification.must_equal "[:zero_terminated, :foo]"
      end
    end

    describe "for a fixed length c-like array of type :foo" do
      it "returns the pair [:c, :foo]" do
	type_info = testclass.new
	mock(type_info).tag { :array }
	stub(type_info).element_type { :foo }
	stub(type_info).zero_terminated? { false }
	stub(type_info).array_type { :c }
	type_info.type_specification.must_equal "[:c, :foo]"
      end
    end

  end

  describe "#subtype_tag_or_class_name" do
    describe "for a simple type" do
      it "returns the string ':void'" do
        mock(subtype = Object.new).tag { :void }
        mock(subtype).pointer? { false }

        mock(info = testclass.new).param_type(0) { subtype }

        assert_equal ":void", info.subtype_tag_or_class_name
      end
    end

    describe "for an array of simple type :foo" do
      it "returns the string ':foo'" do
        mock(subtype = Object.new).tag { :foo }
        mock(subtype).pointer? { false }

        mock(info = testclass.new).param_type(0) { subtype }

        assert_equal ":foo", info.subtype_tag_or_class_name
      end
    end

    describe "for an array of an interface class" do
      it "returns the interface's full class name" do
        mock(subtype = Object.new).tag { :interface }
        mock(subtype).interface_type_name { "-full-type-name-" }
        mock(subtype).pointer? { false }

        mock(info = testclass.new).param_type(0) { subtype }

        assert_equal "-full-type-name-", info.subtype_tag_or_class_name
      end
    end

    describe "for an array of pointer to simple type :foo" do
      it "returns the string '[:pointer, :foo]'" do
        mock(subtype = Object.new).tag { :foo }
        mock(subtype).pointer? { true }

        mock(info = testclass.new).param_type(0) { subtype }

        assert_equal "[:pointer, :foo]", info.subtype_tag_or_class_name
      end
    end
  end
end
