require 'gir_ffi_test_helper'

describe GirFFI::Builders::PropertyBuilder do
  let(:builder) { GirFFI::Builders::PropertyBuilder.new property_info }

  describe "for a property of type :glist" do
    let(:property_info) { get_property_introspection_data("Regress", "TestObj", "list") }
    it "generates the correct getter definition" do
      expected = <<-CODE.reset_indentation
      def list
        _v1 = get_property_basic("list").get_value_plain
        _v2 = GLib::List.wrap(:utf8, _v1)
        _v2
      end
      CODE

      builder.getter_def.must_equal expected
    end
  end

  describe "for a property of type :ghash" do
    let(:property_info) { get_property_introspection_data("Regress", "TestObj", "hash-table") }
    it "generates the correct getter definition" do
      expected = <<-CODE.reset_indentation
      def hash_table
        _v1 = get_property_basic("hash-table").get_value_plain
        _v2 = GLib::HashTable.wrap([:utf8, :gint8], _v1)
        _v2
      end
      CODE

      builder.getter_def.must_equal expected
    end
  end

  describe "for a property of type :utf8" do
    let(:property_info) { get_property_introspection_data("Regress", "TestObj", "string") }
    it "generates the correct getter definition" do
      expected = <<-CODE.reset_indentation
      def string
        get_property_basic("string").get_value
      end
      CODE

      builder.getter_def.must_equal expected
    end
  end
end
