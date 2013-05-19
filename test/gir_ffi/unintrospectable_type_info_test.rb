require 'gir_ffi_test_helper'
require 'gir_ffi/unintrospectable_type_info'

describe GirFFI::UnintrospectableTypeInfo do
  describe "#parent" do
    it "finds the parent's info by gtype" do
      gobject = Object.new
      gir = Object.new

      mock(gobject).type_parent(:some_type) { :foo }
      mock(gir).find_by_gtype(:foo) { :foo_info }

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

      info.parent.must_equal :foo_info
    end
  end

  describe "#interfaces" do
    it "finds interface infos by gtype" do
      gobject = Object.new
      gir = Object.new

      mock(gobject).type_interfaces(:some_type) { [:foo, :bar ] }
      mock(gir).find_by_gtype(:foo) { :foo_info }
      mock(gir).find_by_gtype(:bar) { :bar_info }

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

      info.interfaces.must_equal [:foo_info, :bar_info]
    end

    it "skips interfaces that have no introspection data" do
      gobject = Object.new
      gir = Object.new

      mock(gobject).type_interfaces(:some_type) { [:foo, :bar ] }
      mock(gir).find_by_gtype(:foo) { :foo_info }
      mock(gir).find_by_gtype(:bar) { nil }

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

      info.interfaces.must_equal [:foo_info]
    end
  end

  describe "#g_type" do
    it "returns the passed-in gtype" do
      info = GirFFI::UnintrospectableTypeInfo.new(:some_type)
      info.g_type.must_equal :some_type
    end
  end

  describe "#fields" do
    it "returns an empty array" do
      info = GirFFI::UnintrospectableTypeInfo.new(:some_type)
      info.fields.must_equal []
    end
  end

  describe "#namespace" do
    it "returns the parent class' namespace" do
      gobject = Object.new
      gir = Object.new
      parent_info = Object.new

      mock(gobject).type_parent(:some_type) { :foo }
      mock(gir).find_by_gtype(:foo) { parent_info }
      mock(parent_info).namespace { 'FooNamespace' }

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, gir, gobject)

      info.namespace.must_equal 'FooNamespace'
    end
  end

  describe "#safe_name" do
    it "finds the class name by gtype" do
      gobject = Object.new

      mock(gobject).type_name(:some_type) { 'GSomeType' }

      info = GirFFI::UnintrospectableTypeInfo.new(:some_type, nil, gobject)

      info.safe_name.must_equal 'GSomeType'
    end
  end
end
