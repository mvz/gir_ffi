# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::Builders::ObjectBuilder do
  let(:obj_builder) do
    GirFFI::Builders::ObjectBuilder.new(
      get_introspection_data("Regress", "TestObj"))
  end
  let(:sub_obj_builder) do
    GirFFI::Builders::ObjectBuilder.new(
      get_introspection_data("Regress", "TestSubObj"))
  end
  let(:param_spec_builder) do
    GirFFI::Builders::ObjectBuilder.new(
      get_introspection_data("GObject", "ParamSpec"))
  end

  describe "#find_signal" do
    it 'finds a signal defined on the class itself' do
      sig = obj_builder.find_signal "test"
      _(sig.name).must_equal "test"
    end

    it 'finds a signal defined on a superclass' do
      sig = sub_obj_builder.find_signal "test"
      _(sig.name).must_equal "test"
    end

    it 'finds signals defined on interfaces' do
      skip_below "1.57.2"
      sig = sub_obj_builder.find_signal "interface-signal"
      _(sig.name).must_equal "interface-signal"
    end

    it "returns nil for a signal that doesn't exist" do
      _(obj_builder.find_signal("foo")).must_be_nil
    end
  end

  describe "#find_property" do
    it "finds a property specified on the class itself" do
      prop = obj_builder.find_property("int")
      _(prop.name).must_equal "int"
    end

    it "finds a property specified on the parent class" do
      prop = sub_obj_builder.find_property("int")
      _(prop.name).must_equal "int"
    end

    it "returns nil if the property is not found" do
      _(sub_obj_builder.find_property("this-property-does-not-exist")).must_be_nil
    end
  end

  describe "#object_class_struct" do
    it "returns the class struct type" do
      _(obj_builder.object_class_struct).must_equal Regress::TestObjClass
    end

    it "returns the parent struct type for classes without their own struct" do
      binding_info = get_introspection_data "GObject", "Binding"
      builder = GirFFI::Builders::ObjectBuilder.new binding_info
      _(builder.object_class_struct).must_equal GObject::ObjectClass
    end
  end

  describe "for a struct without defined fields" do
    let(:info) { get_introspection_data "GObject", "Binding" }

    it "uses a single field of the parent struct type as the default layout" do
      _(info.n_fields).must_equal 0

      builder = GirFFI::Builders::ObjectBuilder.new info

      spec = builder.send :layout_specification
      assert_equal [:parent, GObject::Object::Struct, 0], spec
    end
  end

  describe "#eligible_properties" do
    let(:wi_builder) do
      GirFFI::Builders::ObjectBuilder.new(
        get_introspection_data("Regress", "TestWi8021x"))
    end

    it "includes properties that do not have a matching getter method" do
      result = obj_builder.eligible_properties
      _(result.map(&:name)).must_include "double"
    end

    it "skips properties that have a matching getter method" do
      result = wi_builder.eligible_properties
      _(result.map(&:name)).wont_include "testbool"
    end
  end
end
