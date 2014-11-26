require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ITypeInfo do
  let(:klass) {
    Class.new do
      include GirFFI::InfoExt::ITypeInfo
    end
  }

  let(:type_info) { klass.new }
  let(:elmtype_info) { klass.new }
  let(:keytype_info) { klass.new }
  let(:valtype_info) { klass.new }
  let(:iface_info) { Object.new }

  let(:callback_type_info) {
    get_introspection_data('Regress', 'test_callback').args[0].argument_type
  }
  let(:ghash_type_info) {
    get_introspection_data('Regress',
                           'test_ghash_nested_everything_return').return_type
  }

  describe '#to_ffitype' do
    it 'returns an array with elements subtype and size for type :array' do
      mock(type_info).pointer? { false }
      stub(type_info).tag { :array }
      mock(type_info).array_fixed_size { 2 }

      mock(elmtype_info).to_ffitype { :foo }
      mock(type_info).param_type(0) { elmtype_info }

      result = type_info.to_ffitype
      assert_equal [:foo, 2], result
    end

    describe 'for an :interface type' do
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

  describe '#element_type' do
    it 'returns the element type for lists' do
      stub(elmtype_info).tag { :foo }
      mock(elmtype_info).pointer? { false }

      mock(type_info).tag { :glist }
      mock(type_info).param_type(0) { elmtype_info }

      result = type_info.element_type
      result.must_equal :foo
    end

    it 'returns the key and value types for ghashes' do
      stub(keytype_info).tag { :foo }
      mock(keytype_info).pointer? { false }
      stub(valtype_info).tag { :bar }
      mock(valtype_info).pointer? { false }

      mock(type_info).tag { :ghash }
      mock(type_info).param_type(0) { keytype_info }
      mock(type_info).param_type(1) { valtype_info }

      result = type_info.element_type
      result.must_equal [:foo, :bar]
    end

    it 'returns nil for other types' do
      mock(type_info).tag { :foo }

      result = type_info.element_type
      result.must_be_nil
    end

    it 'returns [:pointer, :void] if the element type is a pointer with tag :void' do
      stub(elmtype_info).tag_or_class { [:pointer, :void] }

      mock(type_info).tag { :glist }
      mock(type_info).param_type(0) { elmtype_info }

      assert_equal [:pointer, :void], type_info.element_type
    end
  end

  describe '#flattened_tag' do
    describe 'for a simple type' do
      it 'returns the type tag' do
        stub(type_info).tag { :uint32 }

        type_info.flattened_tag.must_equal :uint32
      end
    end

    describe 'for a zero-terminated array' do
      before do
        stub(type_info).tag { :array }
        stub(type_info).param_type(0) { elmtype_info }
        stub(type_info).zero_terminated? { true }
      end

      describe 'of utf8' do
        it 'returns :strv' do
          stub(elmtype_info).tag { :utf8 }
          stub(elmtype_info).pointer? { true }

          type_info.flattened_tag.must_equal :strv
        end
      end

      describe 'of filename' do
        it 'returns :strv' do
          stub(elmtype_info).tag { :filename }
          stub(elmtype_info).pointer? { true }

          type_info.flattened_tag.must_equal :strv
        end
      end

      describe 'of another type' do
        it 'returns :zero_terminated' do
          stub(elmtype_info).tag { :foo }
          stub(elmtype_info).pointer? { false }

          type_info.flattened_tag.must_equal :zero_terminated
        end
      end
    end

    describe 'for a fixed length c-like array' do
      it 'returns :c' do
        mock(type_info).tag { :array }
        mock(type_info).zero_terminated? { false }
        mock(type_info).array_type { :c }

        type_info.flattened_tag.must_equal :c
      end
    end

    describe 'for a GLib array' do
      it 'returns :c' do
        mock(type_info).tag { :array }
        mock(type_info).zero_terminated? { false }
        mock(type_info).array_type { :array }

        type_info.flattened_tag.must_equal :array
      end
    end
  end

  describe '#tag_or_class' do
    describe 'for a simple type' do
      it "returns the type's tag" do
        stub(type_info).tag { :foo }
        mock(type_info).pointer? { false }

        type_info.tag_or_class.must_equal :foo
      end
    end

    describe 'for utf8 strings' do
      it 'returns the tag :utf8' do
        stub(type_info).tag { :utf8 }
        mock(type_info).pointer? { true }

        type_info.tag_or_class.must_equal :utf8
      end
    end

    describe 'for filename strings' do
      it 'returns the tag :filename' do
        stub(type_info).tag { :filename }
        mock(type_info).pointer? { true }

        type_info.tag_or_class.must_equal :filename
      end
    end

    describe 'for an interface class' do
      let(:interface) { Object.new }

      before do
        stub(type_info).tag { :interface }
        stub(type_info).interface { iface_info }
        mock(type_info).pointer? { false }

        mock(GirFFI::Builder).build_class(iface_info) { interface }
      end

      describe 'when the interface type is :enum' do
        it 'returns the built interface module' do
          stub(iface_info).info_type { :enum }

          type_info.tag_or_class.must_equal interface
        end
      end

      describe 'when the interface type is :object' do
        it 'returns the built interface class' do
          stub(iface_info).info_type { :object }

          type_info.tag_or_class.must_equal interface
        end
      end

      describe 'when the interface type is :struct' do
        it 'returns the built interface class' do
          stub(iface_info).info_type { :struct }

          type_info.tag_or_class.must_equal interface
        end
      end

    end

    describe 'for a callback' do
      it "returns the callback's wrapper class" do
        callback_type_info.tag_or_class.must_equal Regress::TestCallback
      end
    end

    describe 'for a pointer to simple type :foo' do
      it 'returns [:pointer, :foo]' do
        stub(type_info).tag { :foo }
        mock(type_info).pointer? { true }

        type_info.tag_or_class.must_equal [:pointer, :foo]
      end
    end

    describe 'for a pointer to :void' do
      it 'returns [:pointer, :void]' do
        stub(type_info).tag { :void }
        stub(type_info).pointer? { true }

        type_info.tag_or_class.must_equal [:pointer, :void]
      end
    end

    describe 'for a complex nested hash type' do
      it 'returns a representeation of the nested structure' do
        ghash_type_info.tag_or_class.must_equal(
          [:pointer,
           [:ghash,
            :utf8,
            [:pointer,
             [:ghash, :utf8, :utf8]]]])
      end
    end
  end

  describe '#to_callback_ffitype' do
    describe 'for an :interface argument' do
      before do
        stub(type_info).interface { iface_info }
        stub(type_info).tag { :interface }
        stub(type_info).pointer? { false }
      end

      it 'correctly maps a :union argument to :pointer' do
        stub(iface_info).info_type { :union }

        type_info.to_callback_ffitype.must_equal :pointer
      end

      it 'correctly maps a :flags argument to :int32' do
        stub(iface_info).info_type { :flags }

        type_info.to_callback_ffitype.must_equal :int32
      end
    end
  end

  describe '#extra_conversion_arguments' do
    describe 'for normal types' do
      before do
        stub(type_info).tag { :foo }
      end

      it 'returns an empty array' do
        type_info.extra_conversion_arguments.must_equal []
      end
    end

    describe 'for a string' do
      before do
        stub(type_info).tag { :utf8 }
      end

      it 'returns an array containing :utf8' do
        type_info.extra_conversion_arguments.must_equal [:utf8]
      end
    end

    describe 'for a fixed-size array' do
      before do
        stub(type_info).tag { :array }
        stub(type_info).zero_terminated? { false }
        stub(type_info).array_type { :c }
        stub(type_info).array_fixed_size { 3 }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it 'returns an array containing the element type' do
        type_info.extra_conversion_arguments.must_equal [:foo, 3]
      end
    end

    describe 'for a zero-terminated array' do
      before do
        stub(type_info).tag { :array }
        stub(type_info).zero_terminated? { true }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it 'returns an array containing the element type' do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe 'for a GArray' do
      before do
        stub(type_info).tag { :array }
        stub(type_info).zero_terminated? { false }
        stub(type_info).array_type { :array }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it 'returns an array containing the element type' do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe 'for a GHashTable' do
      before do
        stub(type_info).tag { :ghash }
        stub(type_info).param_type(0) { keytype_info }
        stub(type_info).param_type(1) { valtype_info }

        stub(keytype_info).tag_or_class { :foo }
        stub(valtype_info).tag_or_class { :bar }
      end

      it 'returns an array containing the element type pair' do
        type_info.extra_conversion_arguments.must_equal [[:foo, :bar]]
      end
    end

    describe 'for a GList' do
      before do
        stub(type_info).tag { :glist }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it 'returns an array containing the element type' do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe 'for a GSList' do
      before do
        stub(type_info).tag { :gslist }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it 'returns an array containing the element type' do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe 'for a GPtrArray' do
      before do
        stub(type_info).tag { :array }
        stub(type_info).zero_terminated? { false }
        stub(type_info).array_type { :ptr_array }

        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      it 'returns an array containing the element type' do
        type_info.extra_conversion_arguments.must_equal [:foo]
      end
    end

    describe 'for a :callback' do
      before do
        stub(interface_type_info = Object.new).namespace { 'Bar' }
        stub(interface_type_info).name { 'Foo' }

        stub(type_info).tag { :callback }
        stub(type_info).interface { interface_type_info }
      end

      it 'returns an empty array' do
        type_info.extra_conversion_arguments.must_equal []
      end
    end
  end

  describe '#argument_class_name' do
    before do
      stub(type_info).tag { tag }
    end

    describe 'for :gint32' do
      let(:tag) { :gint32 }

      it 'is nil' do
        type_info.argument_class_name.must_be_nil
      end
    end

    describe 'for interfaces' do
      let(:tag) { :interface }

      before do
        stub(type_info).interface { iface_info }
        stub(iface_info).info_type { interface_type }
        stub(iface_info).full_type_name { 'Bar::Foo' }
      end

      describe 'for :struct' do
        let(:interface_type) { :struct }
        it 'equals the struct class name' do
          type_info.argument_class_name.must_equal 'Bar::Foo'
        end
      end

      describe 'for :union' do
        let(:interface_type) { :union }
        it 'equals the union class name' do
          type_info.argument_class_name.must_equal 'Bar::Foo'
        end
      end

      describe 'for :interface' do
        let(:interface_type) { :interface }

        it 'equals the interface module name' do
          type_info.argument_class_name.must_equal 'Bar::Foo'
        end
      end

      describe 'for :object' do
        let(:interface_type) { :object }

        it 'equals the object class name' do
          type_info.argument_class_name.must_equal 'Bar::Foo'
        end
      end

      describe 'for :callback' do
        let(:interface_type) { :callback }

        it 'equals the callback type name' do
          type_info.argument_class_name.must_equal 'Bar::Foo'
        end
      end
    end

    describe 'for :strv' do
      let(:tag) { :strv }

      it 'equals GLib::Strv' do
        type_info.argument_class_name.must_equal 'GLib::Strv'
      end
    end

    describe 'for arrays' do
      let(:tag) { :array }
      before do
        stub(type_info).param_type(0) { elmtype_info }
        stub(elmtype_info).tag_or_class { :foo }
      end

      describe 'for :zero_terminated' do
        before do
          stub(type_info).zero_terminated? { true }
        end

        it 'equals GirFFI::ZeroTerminated' do
          type_info.argument_class_name.must_equal 'GirFFI::ZeroTerminated'
        end
      end

      describe 'for :byte_array' do
        before do
          stub(type_info).zero_terminated? { false }
          stub(type_info).array_type { :byte_array }
        end

        it 'equals GLib::ByteArray' do
          type_info.argument_class_name.must_equal 'GLib::ByteArray'
        end
      end

      describe 'for :ptr_array' do
        before do
          stub(type_info).zero_terminated? { false }
          stub(type_info).array_type { :ptr_array }
        end

        it 'equals GLib::PtrArray' do
          type_info.argument_class_name.must_equal 'GLib::PtrArray'
        end
      end

      describe 'for :array' do
        before do
          stub(type_info).zero_terminated? { false }
          stub(type_info).array_type { :array }
        end

        it 'equals GLib::Array' do
          type_info.argument_class_name.must_equal 'GLib::Array'
        end
      end
    end

    describe 'for :glist' do
      let(:tag) { :glist }

      it 'equals GLib::List' do
        type_info.argument_class_name.must_equal 'GLib::List'
      end
    end

    describe 'for :gslist' do
      let(:tag) { :gslist }

      it 'equals GLib::SList' do
        type_info.argument_class_name.must_equal 'GLib::SList'
      end
    end

    describe 'for :ghash' do
      let(:tag) { :ghash }

      it 'equals GLib::HashTable' do
        type_info.argument_class_name.must_equal 'GLib::HashTable'
      end
    end

    describe 'for :error' do
      let(:tag) { :error }

      it 'equals GLib::Error' do
        type_info.argument_class_name.must_equal 'GLib::Error'
      end
    end
  end

  describe '#g_type' do
    before do
      stub(type_info).tag { tag }
      stub(type_info).pointer? { pointer? }
    end

    describe 'for :void' do
      let(:tag) { :void }
      let(:pointer?) { false }

      it 'equals the none type' do
        GObject.type_name(type_info.g_type).must_equal 'void'
      end
    end

    describe 'for :gboolean' do
      let(:tag) { :gboolean }
      let(:pointer?) { false }

      it 'equals the gboolean type' do
        GObject.type_name(type_info.g_type).must_equal 'gboolean'
      end
    end

    describe 'for :gint32' do
      let(:tag) { :gint32 }
      let(:pointer?) { false }

      it 'equals the gint type' do
        GObject.type_name(type_info.g_type).must_equal 'gint'
      end
    end

    describe 'for :gint64' do
      let(:tag) { :gint64 }
      let(:pointer?) { false }

      it 'equals the gint64 type' do
        GObject.type_name(type_info.g_type).must_equal 'gint64'
      end
    end

    describe 'for :guint64' do
      let(:tag) { :guint64 }
      let(:pointer?) { false }

      it 'equals the guint64 type' do
        GObject.type_name(type_info.g_type).must_equal 'guint64'
      end
    end

    describe 'for pointer to :utf8' do
      let(:tag) { :utf8 }
      let(:pointer?) { true }

      it 'equals the gchararray type' do
        GObject.type_name(type_info.g_type).must_equal 'gchararray'
      end
    end

    describe 'for pointer to :ghash' do
      let(:tag) { :ghash }
      let(:pointer?) { true }

      it 'equals the GHashTable type' do
        GObject.type_name(type_info.g_type).must_equal 'GHashTable'
      end
    end

    describe 'for arrays' do
      let(:tag) { :array }
      let(:pointer?) { true }

      describe 'for pointer to GArray' do
        before do
          stub(type_info).zero_terminated? { false }
          stub(type_info).array_type { :array }
        end

        it 'equals the GArray type' do
          GObject.type_name(type_info.g_type).must_equal 'GArray'
        end
      end

      describe 'for a C array' do
        before do
          stub(type_info).zero_terminated? { false }
          stub(type_info).array_type { :c }
        end

        it 'equals the gpointer type' do
          GObject.type_name(type_info.g_type).must_equal 'gpointer'
        end
      end

      describe 'for a zero-terminated array' do
        before do
          stub(type_info).param_type(0) { elmtype_info }
          stub(type_info).zero_terminated? { true }
        end

        describe 'of utf8' do
          it 'equals the GStrv type' do
            stub(elmtype_info).tag { :utf8 }
            stub(elmtype_info).pointer? { true }

            GObject.type_name(type_info.g_type).must_equal 'GStrv'
          end
        end

        describe 'of filename' do
          it 'equals the GStrv type' do
            stub(elmtype_info).tag { :filename }
            stub(elmtype_info).pointer? { true }

            GObject.type_name(type_info.g_type).must_equal 'GStrv'
          end
        end
      end
    end
  end
end
