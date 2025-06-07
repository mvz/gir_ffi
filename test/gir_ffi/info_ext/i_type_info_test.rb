# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::InfoExt::ITypeInfo do
  let(:info_class) do
    Class.new do
      include GirFFI::InfoExt::ITypeInfo
    end
  end

  let(:type_info) { info_class.new }
  let(:elmtype_info) { info_class.new }
  let(:keytype_info) { info_class.new }
  let(:valtype_info) { info_class.new }
  let(:iface_info) { Object.new }

  let(:callback_type_info) do
    get_introspection_data("Regress", "test_callback").args[0].argument_type
  end
  let(:ghash_type_info) do
    get_introspection_data("Regress",
                           "test_ghash_nested_everything_return").return_type
  end

  describe "#to_ffi_type" do
    it "returns an array with elements subtype and size for type :array" do
      expect(type_info).to receive(:pointer?).and_return false
      allow(type_info).to receive(:tag).and_return :array
      expect(type_info).to receive(:array_fixed_size).and_return 2

      expect(elmtype_info).to receive(:to_ffi_type).and_return :foo
      expect(type_info).to receive(:param_type).with(0).and_return elmtype_info

      result = type_info.to_ffi_type

      assert_equal [:foo, 2], result
    end

    describe "for an :interface type" do
      before do
        allow(type_info).to receive(:interface).and_return iface_info
        allow(type_info).to receive(:tag).and_return :interface
        allow(type_info).to receive(:pointer?).and_return false
      end

      it "maps a the interface's ffi_type" do
        allow(iface_info).to receive(:to_ffi_type).and_return :foo

        _(type_info.to_ffi_type).must_equal :foo
      end
    end
  end

  describe "#element_type" do
    it "returns the element type for lists" do
      allow(elmtype_info).to receive(:tag).and_return :foo
      expect(elmtype_info).to receive(:pointer?).and_return false

      expect(type_info).to receive(:tag).and_return :glist
      expect(type_info).to receive(:param_type).with(0).and_return elmtype_info

      result = type_info.element_type

      _(result).must_equal :foo
    end

    it "returns the key and value types for ghashes" do
      allow(keytype_info).to receive(:tag).and_return :foo
      expect(keytype_info).to receive(:pointer?).and_return false
      allow(valtype_info).to receive(:tag).and_return :bar
      expect(valtype_info).to receive(:pointer?).and_return false

      expect(type_info).to receive(:tag).and_return :ghash
      expect(type_info).to receive(:param_type).with(0).and_return keytype_info
      expect(type_info).to receive(:param_type).with(1).and_return valtype_info

      result = type_info.element_type

      _(result).must_equal [:foo, :bar]
    end

    it "returns nil for other types" do
      expect(type_info).to receive(:tag).and_return :foo

      result = type_info.element_type

      _(result).must_be_nil
    end

    it "returns [:pointer, :void] if the element type is a pointer with tag :void" do
      allow(elmtype_info).to receive(:tag_or_class).and_return [:pointer, :void]

      expect(type_info).to receive(:tag).and_return :glist
      expect(type_info).to receive(:param_type).with(0).and_return elmtype_info

      assert_equal [:pointer, :void], type_info.element_type
    end
  end

  describe "#flattened_tag" do
    describe "for a simple type" do
      it "returns the type tag" do
        allow(type_info).to receive(:tag).and_return :uint32

        _(type_info.flattened_tag).must_equal :uint32
      end
    end

    describe "for a zero-terminated array" do
      before do
        allow(type_info).to receive(:tag).and_return :array
        allow(type_info).to receive(:param_type).with(0).and_return elmtype_info
        allow(type_info).to receive(:zero_terminated?).and_return true
      end

      describe "of utf8" do
        it "returns :strv" do
          allow(elmtype_info).to receive(:tag).and_return :utf8
          allow(elmtype_info).to receive(:pointer?).and_return true

          _(type_info.flattened_tag).must_equal :strv
        end
      end

      describe "of filename" do
        it "returns :strv" do
          allow(elmtype_info).to receive(:tag).and_return :filename
          allow(elmtype_info).to receive(:pointer?).and_return true

          _(type_info.flattened_tag).must_equal :strv
        end
      end

      describe "of another type" do
        it "returns :zero_terminated" do
          allow(elmtype_info).to receive(:tag).and_return :foo
          allow(elmtype_info).to receive(:pointer?).and_return false

          _(type_info.flattened_tag).must_equal :zero_terminated
        end
      end
    end

    describe "for a fixed length c-like array" do
      it "returns :c" do
        expect(type_info).to receive(:tag).and_return :array
        expect(type_info).to receive(:zero_terminated?).and_return false
        expect(type_info).to receive(:array_type).and_return :c

        _(type_info.flattened_tag).must_equal :c
      end
    end

    describe "for a GLib array" do
      it "returns :c" do
        expect(type_info).to receive(:tag).and_return :array
        expect(type_info).to receive(:zero_terminated?).and_return false
        expect(type_info).to receive(:array_type).and_return :array

        _(type_info.flattened_tag).must_equal :array
      end
    end
  end

  describe "#tag_or_class" do
    describe "for a simple type" do
      it "returns the type's tag" do
        allow(type_info).to receive(:tag).and_return :foo
        expect(type_info).to receive(:pointer?).and_return false

        _(type_info.tag_or_class).must_equal :foo
      end
    end

    describe "for utf8 strings" do
      it "returns the tag :utf8" do
        allow(type_info).to receive(:tag).and_return :utf8
        expect(type_info).to receive(:pointer?).and_return true

        _(type_info.tag_or_class).must_equal :utf8
      end
    end

    describe "for filename strings" do
      it "returns the tag :filename" do
        allow(type_info).to receive(:tag).and_return :filename
        expect(type_info).to receive(:pointer?).and_return true

        _(type_info.tag_or_class).must_equal :filename
      end
    end

    describe "for an interface class" do
      let(:interface) { Object.new }

      before do
        allow(type_info).to receive(:tag).and_return :interface
        allow(type_info).to receive(:interface).and_return iface_info
        expect(type_info).to receive(:pointer?).and_return false

        expect(GirFFI::Builder)
          .to receive(:build_class).with(iface_info).and_return interface
      end

      describe "when the interface type is :enum" do
        it "returns the built interface module" do
          allow(iface_info).to receive(:info_type).and_return :enum

          _(type_info.tag_or_class).must_equal interface
        end
      end

      describe "when the interface type is :object" do
        it "returns the built interface class" do
          allow(iface_info).to receive(:info_type).and_return :object

          _(type_info.tag_or_class).must_equal interface
        end
      end

      describe "when the interface type is :struct" do
        it "returns the built interface class" do
          allow(iface_info).to receive(:info_type).and_return :struct

          _(type_info.tag_or_class).must_equal interface
        end
      end
    end

    describe "for a callback" do
      it "returns the callback's wrapper class" do
        _(callback_type_info.tag_or_class).must_equal Regress::TestCallback
      end
    end

    describe "for a pointer to simple type :foo" do
      it "returns [:pointer, :foo]" do
        allow(type_info).to receive(:tag).and_return :foo
        expect(type_info).to receive(:pointer?).and_return true

        _(type_info.tag_or_class).must_equal [:pointer, :foo]
      end
    end

    describe "for a pointer to :void" do
      it "returns [:pointer, :void]" do
        allow(type_info).to receive(:tag).and_return :void
        allow(type_info).to receive(:pointer?).and_return true

        _(type_info.tag_or_class).must_equal [:pointer, :void]
      end
    end

    describe "for a complex nested hash type" do
      it "returns a representeation of the nested structure" do
        _(ghash_type_info.tag_or_class).must_equal(
          [:pointer,
           [:ghash,
            :utf8,
            [:pointer,
             [:ghash, :utf8, :utf8]]]])
      end
    end
  end

  describe "#to_callback_ffi_type" do
    describe "for an :interface argument" do
      before do
        allow(type_info).to receive(:interface).and_return iface_info
        allow(type_info).to receive(:tag).and_return :interface
        allow(type_info).to receive(:pointer?).and_return false
      end

      it "delegates to interface info" do
        allow(iface_info).to receive(:to_callback_ffi_type).and_return :some_ffi_type

        _(type_info.to_callback_ffi_type).must_equal :some_ffi_type
      end
    end
  end

  describe "#extra_conversion_arguments" do
    describe "for normal types" do
      before do
        allow(type_info).to receive(:tag).and_return :foo
      end

      it "returns an empty array" do
        _(type_info.extra_conversion_arguments).must_equal []
      end
    end

    describe "for a fixed-size array" do
      before do
        allow(type_info).to receive(:tag).and_return :array
        allow(type_info).to receive(:zero_terminated?).and_return false
        allow(type_info).to receive(:array_type).and_return :c
        allow(type_info).to receive(:array_fixed_size).and_return 3

        allow(type_info).to receive(:param_type).with(0).and_return elmtype_info
        allow(elmtype_info).to receive(:tag_or_class).and_return :foo
      end

      it "returns an array containing the element type" do
        _(type_info.extra_conversion_arguments).must_equal [:foo, 3]
      end
    end

    describe "for a zero-terminated array" do
      before do
        allow(type_info).to receive(:tag).and_return :array
        allow(type_info).to receive(:zero_terminated?).and_return true

        allow(type_info).to receive(:param_type).with(0).and_return elmtype_info
        allow(elmtype_info).to receive(:tag_or_class).and_return :foo
      end

      it "returns an array containing the element type" do
        _(type_info.extra_conversion_arguments).must_equal [:foo]
      end
    end

    describe "for a GArray" do
      before do
        allow(type_info).to receive(:tag).and_return :array
        allow(type_info).to receive(:zero_terminated?).and_return false
        allow(type_info).to receive(:array_type).and_return :array

        allow(type_info).to receive(:param_type).with(0).and_return elmtype_info
        allow(elmtype_info).to receive(:tag_or_class).and_return :foo
      end

      it "returns an array containing the element type" do
        _(type_info.extra_conversion_arguments).must_equal [:foo]
      end
    end

    describe "for a GHashTable" do
      before do
        allow(type_info).to receive(:tag).and_return :ghash
        allow(type_info).to receive(:param_type).with(0).and_return keytype_info
        allow(type_info).to receive(:param_type).with(1).and_return valtype_info

        allow(keytype_info).to receive(:tag_or_class).and_return :foo
        allow(valtype_info).to receive(:tag_or_class).and_return :bar
      end

      it "returns an array containing the element type pair" do
        _(type_info.extra_conversion_arguments).must_equal [[:foo, :bar]]
      end
    end

    describe "for a GList" do
      before do
        allow(type_info).to receive(:tag).and_return :glist

        allow(type_info).to receive(:param_type).with(0).and_return elmtype_info
        allow(elmtype_info).to receive(:tag_or_class).and_return :foo
      end

      it "returns an array containing the element type" do
        _(type_info.extra_conversion_arguments).must_equal [:foo]
      end
    end

    describe "for a GSList" do
      before do
        allow(type_info).to receive(:tag).and_return :gslist

        allow(type_info).to receive(:param_type).with(0).and_return elmtype_info
        allow(elmtype_info).to receive(:tag_or_class).and_return :foo
      end

      it "returns an array containing the element type" do
        _(type_info.extra_conversion_arguments).must_equal [:foo]
      end
    end

    describe "for a GPtrArray" do
      before do
        allow(type_info).to receive(:tag).and_return :array
        allow(type_info).to receive(:zero_terminated?).and_return false
        allow(type_info).to receive(:array_type).and_return :ptr_array

        allow(type_info).to receive(:param_type).with(0).and_return elmtype_info
        allow(elmtype_info).to receive(:tag_or_class).and_return :foo
      end

      it "returns an array containing the element type" do
        _(type_info.extra_conversion_arguments).must_equal [:foo]
      end
    end

    describe "for a :callback" do
      before do
        allow(interface_type_info = Object.new).to receive(:namespace).and_return "Bar"
        allow(interface_type_info).to receive(:name).and_return "Foo"

        allow(type_info).to receive(:tag).and_return :callback
        allow(type_info).to receive(:interface).and_return interface_type_info
      end

      it "returns an empty array" do
        _(type_info.extra_conversion_arguments).must_equal []
      end
    end
  end

  describe "#argument_class_name" do
    before do
      allow(type_info).to receive(:tag).and_return tag
    end

    describe "for :gint32" do
      let(:tag) { :gint32 }

      it "is nil" do
        _(type_info.argument_class_name).must_be_nil
      end
    end

    describe "for interfaces" do
      let(:tag) { :interface }

      before do
        allow(type_info).to receive(:interface).and_return iface_info
        allow(iface_info).to receive(:info_type).and_return interface_type
        allow(iface_info).to receive(:full_name).and_return "Bar::Foo"
      end

      describe "for :struct" do
        let(:interface_type) { :struct }

        it "equals the struct class name" do
          _(type_info.argument_class_name).must_equal "Bar::Foo"
        end
      end

      describe "for :union" do
        let(:interface_type) { :union }

        it "equals the union class name" do
          _(type_info.argument_class_name).must_equal "Bar::Foo"
        end
      end

      describe "for :interface" do
        let(:interface_type) { :interface }

        it "equals the interface module name" do
          _(type_info.argument_class_name).must_equal "Bar::Foo"
        end
      end

      describe "for :object" do
        let(:interface_type) { :object }

        it "equals the object class name" do
          _(type_info.argument_class_name).must_equal "Bar::Foo"
        end
      end

      describe "for :callback" do
        let(:interface_type) { :callback }

        it "equals the callback type name" do
          _(type_info.argument_class_name).must_equal "Bar::Foo"
        end
      end
    end

    describe "for :strv" do
      let(:tag) { :strv }

      it "equals GLib::Strv" do
        _(type_info.argument_class_name).must_equal "GLib::Strv"
      end
    end

    describe "for arrays" do
      let(:tag) { :array }
      before do
        allow(type_info).to receive(:param_type).with(0).and_return elmtype_info
        allow(elmtype_info).to receive(:tag_or_class).and_return :foo
      end

      describe "for :zero_terminated" do
        before do
          allow(type_info).to receive(:zero_terminated?).and_return true
        end

        it "equals GirFFI::ZeroTerminated" do
          _(type_info.argument_class_name).must_equal "GirFFI::ZeroTerminated"
        end
      end

      describe "for :byte_array" do
        before do
          allow(type_info).to receive(:zero_terminated?).and_return false
          allow(type_info).to receive(:array_type).and_return :byte_array
        end

        it "equals GLib::ByteArray" do
          _(type_info.argument_class_name).must_equal "GLib::ByteArray"
        end
      end

      describe "for :ptr_array" do
        before do
          allow(type_info).to receive(:zero_terminated?).and_return false
          allow(type_info).to receive(:array_type).and_return :ptr_array
        end

        it "equals GLib::PtrArray" do
          _(type_info.argument_class_name).must_equal "GLib::PtrArray"
        end
      end

      describe "for :array" do
        before do
          allow(type_info).to receive(:zero_terminated?).and_return false
          allow(type_info).to receive(:array_type).and_return :array
        end

        it "equals GLib::Array" do
          _(type_info.argument_class_name).must_equal "GLib::Array"
        end
      end
    end

    describe "for :glist" do
      let(:tag) { :glist }

      it "equals GLib::List" do
        _(type_info.argument_class_name).must_equal "GLib::List"
      end
    end

    describe "for :gslist" do
      let(:tag) { :gslist }

      it "equals GLib::SList" do
        _(type_info.argument_class_name).must_equal "GLib::SList"
      end
    end

    describe "for :ghash" do
      let(:tag) { :ghash }

      it "equals GLib::HashTable" do
        _(type_info.argument_class_name).must_equal "GLib::HashTable"
      end
    end

    describe "for :error" do
      let(:tag) { :error }

      it "equals GLib::Error" do
        _(type_info.argument_class_name).must_equal "GLib::Error"
      end
    end
  end

  describe "#gtype" do
    before do
      allow(type_info).to receive(:tag).and_return tag
      allow(type_info).to receive(:pointer?).and_return pointer?
    end

    describe "for non-pointers" do
      let(:pointer?) { false }
      describe "for :void" do
        let(:tag) { :void }

        it "equals the none type" do
          _(GObject.type_name(type_info.gtype)).must_equal "void"
        end
      end

      describe "for :gboolean" do
        let(:tag) { :gboolean }

        it "equals the gboolean type" do
          _(GObject.type_name(type_info.gtype)).must_equal "gboolean"
        end
      end

      describe "for :gint32" do
        let(:tag) { :gint32 }

        it "equals the gint type" do
          _(GObject.type_name(type_info.gtype)).must_equal "gint"
        end
      end

      describe "for :gint64" do
        let(:tag) { :gint64 }

        it "equals the gint64 type" do
          _(GObject.type_name(type_info.gtype)).must_equal "gint64"
        end
      end

      describe "for :guint64" do
        let(:tag) { :guint64 }

        it "equals the guint64 type" do
          _(GObject.type_name(type_info.gtype)).must_equal "guint64"
        end
      end
    end

    describe "for pointers" do
      let(:pointer?) { true }

      describe "to :void" do
        let(:tag) { :void }

        it "equals the gpointer type" do
          _(GObject.type_name(type_info.gtype)).must_equal "gpointer"
        end
      end

      describe "to :utf8" do
        let(:tag) { :utf8 }

        it "equals the gchararray type" do
          _(GObject.type_name(type_info.gtype)).must_equal "gchararray"
        end
      end

      describe "to :ghash" do
        let(:tag) { :ghash }

        it "equals the GHashTable type" do
          _(GObject.type_name(type_info.gtype)).must_equal "GHashTable"
        end
      end

      describe "to :glist" do
        let(:tag) { :glist }

        it "equals the pointer type" do
          _(GObject.type_name(type_info.gtype)).must_equal "gpointer"
        end
      end

      describe "to :error" do
        let(:tag) { :error }

        it "equals the gpointer type" do
          _(GObject.type_name(type_info.gtype)).must_equal "gpointer"
        end
      end

      describe "to :guint32" do
        let(:tag) { :guint32 }

        it "equals the gpointer type" do
          _(GObject.type_name(type_info.gtype)).must_equal "gpointer"
        end
      end
    end

    describe "for arrays" do
      let(:tag) { :array }
      let(:pointer?) { true }

      describe "for pointer to GArray" do
        before do
          allow(type_info).to receive(:zero_terminated?).and_return false
          allow(type_info).to receive(:array_type).and_return :array
        end

        it "equals the GArray type" do
          _(GObject.type_name(type_info.gtype)).must_equal "GArray"
        end
      end

      describe "for a C array" do
        before do
          allow(type_info).to receive(:zero_terminated?).and_return false
          allow(type_info).to receive(:array_type).and_return :c
        end

        it "equals the gpointer type" do
          _(GObject.type_name(type_info.gtype)).must_equal "gpointer"
        end
      end

      describe "for a zero-terminated array" do
        before do
          allow(type_info).to receive(:param_type).with(0).and_return elmtype_info
          allow(type_info).to receive(:zero_terminated?).and_return true
        end

        describe "of utf8" do
          it "equals the GStrv type" do
            allow(elmtype_info).to receive(:tag).and_return :utf8
            allow(elmtype_info).to receive(:pointer?).and_return true

            _(GObject.type_name(type_info.gtype)).must_equal "GStrv"
          end
        end

        describe "of filename" do
          it "equals the GStrv type" do
            allow(elmtype_info).to receive(:tag).and_return :filename
            allow(elmtype_info).to receive(:pointer?).and_return true

            _(GObject.type_name(type_info.gtype)).must_equal "GStrv"
          end
        end
      end
    end
  end
end
