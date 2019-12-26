# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::Builders::StructBuilder do
  describe "#layout_specification" do
    it "returns the correct layout for Regress::TestStructA" do
      info = get_introspection_data "Regress", "TestStructA"
      builder = GirFFI::Builders::StructBuilder.new info
      _(builder.layout_specification).must_equal [:some_int, :int32, 0,
                                                  :some_int8, :int8, 4,
                                                  :some_double, :double, 8,
                                                  :some_enum, Regress::TestEnum, 16]
    end

    describe "for a struct with a simple layout" do
      before do
        @field = Object.new

        @struct = Object.new
        allow(@struct).to receive(:namespace).and_return "Foo"
        allow(@struct).to receive(:safe_name).and_return "Bar"
        allow(@struct).to receive(:fields).and_return [@field]

        @builder = GirFFI::Builders::StructBuilder.new @struct
      end

      it "creates the correct layout specification" do
        expect(@field).to receive(:layout_specification).and_return [:bar, :int32, 0]
        spec = @builder.layout_specification
        assert_equal [:bar, :int32, 0], spec
      end
    end

    describe "for a struct with a layout with a complex type" do
      it "does not flatten the complex type specification" do
        expect(simplefield = Object.new)
          .to receive(:layout_specification).and_return [:bar, :foo, 0]
        expect(complexfield = Object.new)
          .to receive(:layout_specification).and_return [:baz, [:qux, 2], 0]
        expect(struct = Object.new)
          .to receive(:fields).and_return [simplefield, complexfield]

        allow(struct).to receive(:safe_name).and_return "Bar"
        allow(struct).to receive(:namespace).and_return "Foo"

        builder = GirFFI::Builders::StructBuilder.new struct
        spec = builder.layout_specification
        assert_equal [:bar, :foo, 0, :baz, [:qux, 2], 0], spec
      end
    end
  end

  describe "#superclass" do
    it "returns StructBase for a normal struct" do
      info = get_introspection_data "Regress", "TestStructA"
      builder = GirFFI::Builders::StructBuilder.new info
      _(builder.superclass).must_equal GirFFI::StructBase
    end

    it "returns BoxedBase for a boxed type" do
      info = get_introspection_data "Regress", "TestSimpleBoxedB"
      builder = GirFFI::Builders::StructBuilder.new info
      _(builder.superclass).must_equal GirFFI::BoxedBase
    end

    it "raises an error for a type class" do
      info = get_introspection_data "GIMarshallingTests", "SubSubObjectClass"
      builder = GirFFI::Builders::StructBuilder.new info
      _(proc { builder.superclass }).must_raise RuntimeError
    end
  end
end
