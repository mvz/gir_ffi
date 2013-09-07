require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ITypeInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::ITypeInfo
  end }
  let(:type_info) { klass.new }
  let(:elmtype_info) { klass.new }
  let(:keytype_info) { klass.new }
  let(:valtype_info) { klass.new }
  let(:iface_info) { Object.new }

  describe "#to_ffitype" do
    it "returns an array with elements subtype and size for type :array" do
      mock(type_info).pointer? { false }
      stub(type_info).tag { :array }
      mock(type_info).array_fixed_size { 2 }

      mock(elmtype_info).to_ffitype { :foo }
      mock(type_info).param_type(0) { elmtype_info }

      result = type_info.to_ffitype
      assert_equal [:foo, 2], result
    end

    describe "for an :interface type" do
      before do
        stub(type_info).interface { iface_info }
        stub(type_info).tag { :interface }
        stub(type_info).pointer? { false }
      end

      it "maps a the interface's ffitype" do
        stub(iface_info).to_ffitype { :foo }

        type_info.to_ffitype.must_equal :foo
      end
    end
  end

  describe "#element_type" do
    it "returns the element type for lists" do
      stub(elmtype_info).tag { :foo }
      mock(elmtype_info).pointer? { false }

      mock(type_info).tag {:glist}
      mock(type_info).param_type(0) { elmtype_info }

      result = type_info.element_type
      result.must_equal :foo
    end

    it "returns the key and value types for ghashes" do
      stub(keytype_info).tag { :foo }
      mock(keytype_info).pointer? { false }
      stub(valtype_info).tag { :bar }
      mock(valtype_info).pointer? { false }

      mock(type_info).tag {:ghash}
      mock(type_info).param_type(0) { keytype_info }
      mock(type_info).param_type(1) { valtype_info }

      result = type_info.element_type
      result.must_equal [:foo, :bar]
    end

    it "returns nil for other types" do
      mock(type_info).tag {:foo}

      result = type_info.element_type
      result.must_be_nil
    end

    it "returns [:pointer, :void] if the element type is a pointer with tag :void" do
      stub(elmtype_info).tag_or_class { [:pointer, :void] }

      mock(type_info).tag {:glist}
      mock(type_info).param_type(0) { elmtype_info }

      assert_equal [:pointer, :void], type_info.element_type
    end
  end

  describe "#flattened_tag" do
    describe "for a simple type" do
      it "returns the type tag" do
        stub(type_info).tag { :uint32 }

        type_info.flattened_tag.must_equal :uint32
      end
    end

    describe "for a zero-terminated array" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).param_type(0) { elmtype_info }
        stub(type_info).zero_terminated? { true }
      end

      describe "of utf8" do
        it "returns :strv" do
          stub(elmtype_info).tag { :utf8 }
          stub(elmtype_info).pointer? { true }

          type_info.flattened_tag.must_equal :strv
        end
      end

      describe "of filename" do
        it "returns :strv" do
          stub(elmtype_info).tag { :filename }
          stub(elmtype_info).pointer? { true }

          type_info.flattened_tag.must_equal :strv
        end
      end

      describe "of another type" do
        it "returns :zero_terminated" do
          stub(elmtype_info).tag { :foo }
          stub(elmtype_info).pointer? { false }

          type_info.flattened_tag.must_equal :zero_terminated
        end
      end
    end

    describe "for a fixed length c-like array" do
      it "returns :c" do
        mock(type_info).tag { :array }
        mock(type_info).zero_terminated? { false }
        mock(type_info).array_type { :c }

        type_info.flattened_tag.must_equal :c
      end
    end

    describe "for a GLib array" do
      it "returns :c" do
        mock(type_info).tag { :array }
        mock(type_info).zero_terminated? { false }
        mock(type_info).array_type { :array }

        type_info.flattened_tag.must_equal :array
      end
    end
  end

  describe "#subtype_tag_or_class" do
    describe "without a parameter" do
      it "returns the result of calling #tag_or_class on the first param_type" do
        mock(elmtype_info).tag_or_class { :foo }

        mock(type_info).param_type(0) { elmtype_info }

        type_info.subtype_tag_or_class.must_equal :foo
      end
    end
  end

  describe "#tag_or_class" do
    describe "for a simple type" do
      it "returns the type's tag" do
        stub(type_info).tag { :foo }
        mock(type_info).pointer? { false }

        type_info.tag_or_class.must_equal :foo
      end
    end

    describe "for utf8 strings" do
      it "returns the tag :utf8" do
        stub(type_info).tag { :utf8 }
        mock(type_info).pointer? { true }

        type_info.tag_or_class.must_equal :utf8
      end
    end

    describe "for filename strings" do
      it "returns the tag :filename" do
        stub(type_info).tag { :filename }
        mock(type_info).pointer? { true }

        type_info.tag_or_class.must_equal :filename
      end
    end

    describe "for an interface class" do
      let(:interface) { Object.new }

      before do
        stub(type_info).tag { :interface }
        stub(type_info).interface { iface_info }
        mock(type_info).pointer? { false }

        mock(GirFFI::Builder).build_class(iface_info) { interface }
      end

      describe "when the interface type is :enum" do
        it "returns the built interface module" do
          stub(iface_info).info_type { :enum }

          type_info.tag_or_class.must_equal interface
        end
      end

      describe "when the interface type is :object" do
        it "returns an array with elements :pointer and built interface class" do
          stub(iface_info).info_type { :object }

          type_info.tag_or_class.must_equal [:pointer, interface]
        end
      end

      describe "when the interface type is :struct" do
        it "returns the built interface class" do
          stub(iface_info).info_type { :struct }

          type_info.tag_or_class.must_equal interface
        end
      end
    end

    describe "for a pointer to simple type :foo" do
      it "returns [:pointer, :foo]" do
        stub(type_info).tag { :foo }
        mock(type_info).pointer? { true }

        type_info.tag_or_class.must_equal [:pointer, :foo]
      end
    end

    describe "for a pointer to :void" do
      it "returns [:pointer, :void]" do
        stub(type_info).tag { :void }
        stub(type_info).pointer? { true }

        type_info.tag_or_class.must_equal [:pointer, :void]
      end
    end
  end

  describe "#to_callback_ffitype" do
    describe "for an :interface argument" do
      before do
        stub(type_info).interface { iface_info }
        stub(type_info).tag { :interface }
        stub(type_info).pointer? { false }
      end

      it "correctly maps a :union argument to :pointer" do
        stub(iface_info).info_type { :union }

        type_info.to_callback_ffitype.must_equal :pointer
      end

      it "correctly maps a :flags argument to :int32" do
        stub(iface_info).info_type { :flags }

        type_info.to_callback_ffitype.must_equal :int32
      end
    end
  end

  describe "#extra_conversion_arguments" do
    describe "for normal types" do
      before do
        stub(type_info).tag { :foo }
      end

      it "returns an empty array" do
        type_info.extra_conversion_arguments.must_equal []
      end
    end

    describe "for a string" do
      before do
        stub(type_info).tag { :utf8 }
      end

      it "returns an array containing :utf8" do
        type_info.extra_conversion_arguments.must_equal [:utf8]
      end
    end

    describe "for a fixed-size array" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).zero_terminated? { false }
        stub(type_info).array_type { :c }
        stub(type_info).array_fixed_size { 3 }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it "returns an array containing the element type" do
        type_info.extra_conversion_arguments.must_equal [:foo, 3]
      end
    end

    describe "for a zero-terminated array" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).zero_terminated? { true }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it "returns an array containing the element type" do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe "for a GArray" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).zero_terminated? { false }
        stub(type_info).array_type { :array }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it "returns an array containing the element type" do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe "for a GHashTable" do
      before do
        stub(type_info).tag {:ghash}
        stub(type_info).param_type(0) { keytype_info }
        stub(type_info).param_type(1) { valtype_info }

        stub(keytype_info).tag_or_class { :foo }
        stub(valtype_info).tag_or_class { :bar }
      end

      it "returns an array containing the element type pair" do
        type_info.extra_conversion_arguments.must_equal [[:foo, :bar]]
      end
    end

    describe "for a GList" do
      before do
        stub(type_info).tag { :glist }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it "returns an array containing the element type" do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe "for a GSList" do
      before do
        stub(type_info).tag { :gslist }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it "returns an array containing the element type" do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe "for a GPtrArray" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).zero_terminated? { false }
        stub(type_info).array_type { :ptr_array }


        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it "returns an array containing the element type" do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe "for a :callback" do
      before do
        stub(interface_type_info = Object.new).namespace { "Bar" }
        stub(interface_type_info).name { "Foo" }

        stub(type_info).tag { :callback }
        stub(type_info).interface { interface_type_info }
      end

      it "has the correct value for #pre" do
        type_info.extra_conversion_arguments.must_equal ["Bar", "Foo"]
      end
    end
  end
end
