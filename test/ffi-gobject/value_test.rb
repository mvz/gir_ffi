require 'gir_ffi_test_helper'

require 'ffi-gobject'

describe GObject::Value do
  describe "::Struct" do
    describe "layout" do
      let(:layout) { GObject::Value::Struct.layout }

      it "consists of :g_type and :data" do
        layout.members.must_equal [:g_type, :data]
      end

      it "has an array as its second element" do
        types = layout.fields.map(&:type)
        types[1].class.must_equal FFI::Type::Array
      end
    end
  end

  describe "::wrap_ruby_value" do
    it "wraps a boolean false" do
      gv = GObject::Value.wrap_ruby_value false
      assert_instance_of GObject::Value, gv
      assert_equal false, gv.get_boolean
    end

    it "wraps a boolean true" do
      gv = GObject::Value.wrap_ruby_value true
      assert_instance_of GObject::Value, gv
      assert_equal true, gv.get_boolean
    end

    it "wraps an Integer" do
      gv = GObject::Value.wrap_ruby_value 42
      assert_equal 42, gv.get_int
    end

    it "wraps a String" do
      gv = GObject::Value.wrap_ruby_value "Some Random String"
      assert_equal "Some Random String", gv.get_string
    end
  end

  describe "#ruby_value" do
    it "unwraps a boolean false" do
      gv = GObject::Value.wrap_ruby_value false
      result = gv.ruby_value
      assert_equal false, result
    end

    it "unwraps a boolean true" do
      gv = GObject::Value.wrap_ruby_value true
      result = gv.ruby_value
      assert_equal true, result
    end
  end

  describe "::from" do
    it "creates a gint GValue from a Ruby Integer" do
      gv = GObject::Value.from 21
      gv.current_gtype_name.must_equal "gint"
      gv.ruby_value.must_equal 21
    end

    it "returns its argument if given a GValue" do
      gv = GObject::Value.from 21
      gv2 = GObject::Value.from gv
      gv2.current_gtype_name.must_equal "gint"
      gv2.ruby_value.must_equal 21
    end
  end
end

