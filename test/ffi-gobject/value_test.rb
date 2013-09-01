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

  describe "#set_value" do
    it "handles int64 values" do
      value = 0x1234_5678_9012_3456
      gv = GObject::Value.for_g_type GObject::TYPE_INT64
      gv.set_value value
      gv.get_int64.must_equal value
    end

    it "handles char values" do
      value = 83
      gv = GObject::Value.for_g_type GObject::TYPE_CHAR
      gv.set_value value
      gv.get_char.must_equal value
    end

    it "handles long values" do
      value = 0x1234_5678_9012_3456
      gv = GObject::Value.for_g_type GObject::TYPE_LONG
      gv.set_value value
      gv.get_long.must_equal value
    end
  end

  describe "#get_value" do
    it "unwraps a boolean false" do
      gv = GObject::Value.wrap_ruby_value false
      result = gv.get_value
      assert_equal false, result
    end

    it "unwraps a boolean true" do
      gv = GObject::Value.wrap_ruby_value true
      result = gv.get_value
      assert_equal true, result
    end

    it "unwraps an int64" do
      value = 0x1234_5678_9012_3456
      gv = GObject::Value.for_g_type GObject::TYPE_INT64
      gv.set_int64 value
      gv.get_value.must_equal value
    end

    it "unwraps a char" do
      value = 3
      gv = GObject::Value.for_g_type GObject::TYPE_CHAR
      gv.set_char value
      gv.get_value.must_equal value
    end

    it "unwraps an long" do
      value = 0x1234_5678_9012_3456
      gv = GObject::Value.for_g_type GObject::TYPE_LONG
      gv.set_long value
      gv.get_value.must_equal value
    end

    it "works with a ByteArray" do
      ba = GLib::ByteArray.new.append("some bytes")
      v = GObject::Value.for_g_type GObject.type_from_name("GByteArray")
      v.set_boxed ba

      result = v.get_value

      result.to_string.must_equal "some bytes"
      result.must_be_kind_of GLib::ByteArray
    end
  end

  describe "::from" do
    it "creates a gint GValue from a Ruby Integer" do
      gv = GObject::Value.from 21
      gv.current_gtype_name.must_equal "gint"
      gv.get_value.must_equal 21
    end

    it "returns its argument if given a GValue" do
      gv = GObject::Value.from 21
      gv2 = GObject::Value.from gv
      gv2.current_gtype_name.must_equal "gint"
      gv2.get_value.must_equal 21
    end
  end

  describe "#set_value" do
    before do
      GirFFI.setup :GIMarshallingTests
    end

    it "raises an error when setting an incompatible object type" do
      o = GIMarshallingTests::Object.new 1
      v = GObject::Value.new.init(GIMarshallingTests::OverridesObject.get_gtype)
      proc { v.set_value o }.must_raise ArgumentError
    end

    it "works with a ByteArray" do
      ba = GLib::ByteArray.new.append("some bytes")
      v = GObject::Value.new.init(GObject.type_from_name("GByteArray"))
      v.set_value ba
      v.get_value.to_string.must_equal "some bytes"
    end
  end
end
