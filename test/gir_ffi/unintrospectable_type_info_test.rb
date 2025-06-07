# frozen_string_literal: true

require "gir_ffi_test_helper"
require "gir_ffi/unintrospectable_type_info"

describe GirFFI::UnintrospectableTypeInfo do
  describe "#info_type" do
    it "returns :unintrospectable" do
      info = GirFFI::UnintrospectableTypeInfo.new :some_type

      _(info.info_type).must_equal :unintrospectable
    end
  end

  describe "#parent" do
    describe "when the GIR knows about the parent gtype" do
      it "finds the parent's info by gtype" do
        gobject = Object.new
        gir = Object.new

        expect(gobject).to receive(:type_parent).with(:some_type).and_return :foo
        expect(gir).to receive(:find_by_gtype).with(:foo).and_return :foo_info

        info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

        _(info.parent).must_equal :foo_info
      end
    end

    describe "when the GIR does not know about the parent gtype" do
      it "creates a new UnintrospectableTypeInfo from the parent gtype" do
        gobject = Object.new
        gir = Object.new

        expect(gobject).to receive(:type_parent).with(:some_type).and_return :foo
        expect(gir).to receive(:find_by_gtype).with(:foo).and_return nil

        info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

        _(info.parent.g_type).must_equal :foo
      end
    end
  end

  describe "#interfaces" do
    it "finds interface infos by gtype" do
      gobject = Object.new
      gir = Object.new

      expect(gobject).to receive(:type_interfaces).with(:some_type).and_return [:foo, :bar]
      expect(gir).to receive(:find_by_gtype).with(:foo).and_return :foo_info
      expect(gir).to receive(:find_by_gtype).with(:bar).and_return :bar_info

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

      _(info.interfaces).must_equal [:foo_info, :bar_info]
    end

    it "skips interfaces that have no introspection data" do
      gobject = Object.new
      gir = Object.new

      expect(gobject).to receive(:type_interfaces).with(:some_type).and_return [:foo, :bar]
      expect(gir).to receive(:find_by_gtype).with(:foo).and_return :foo_info
      expect(gir).to receive(:find_by_gtype).with(:bar).and_return nil

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

      _(info.interfaces).must_equal [:foo_info]
    end
  end

  describe "#g_type" do
    it "returns the passed-in gtype" do
      info = GirFFI::UnintrospectableTypeInfo.new(:some_type)

      _(info.g_type).must_equal :some_type
    end
  end

  describe "#fields" do
    it "returns an empty array" do
      info = GirFFI::UnintrospectableTypeInfo.new(:some_type)

      _(info.fields).must_equal []
    end
  end

  describe "#namespace" do
    it "returns the parent class' namespace" do
      gobject = Object.new
      gir = Object.new
      parent_info = Object.new

      expect(gobject).to receive(:type_parent).with(:some_type).and_return :foo
      expect(gir).to receive(:find_by_gtype).with(:foo).and_return parent_info
      expect(parent_info).to receive(:namespace).and_return "FooNamespace"

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

      _(info.namespace).must_equal "FooNamespace"
    end
  end

  describe "#safe_name" do
    it "finds the class name by gtype" do
      gobject = Object.new

      expect(gobject).to receive(:type_name).with(:some_type).and_return "GSomeType"

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, nil, gobject)

      _(info.safe_name).must_equal "GSomeType"
    end
  end

  describe "#find_signal" do
    it "indicates that no signals can be found" do
      info = GirFFI::UnintrospectableTypeInfo.new(:some_type)
      result = info.find_signal "any"

      _(result).must_be_nil
    end
  end
end
