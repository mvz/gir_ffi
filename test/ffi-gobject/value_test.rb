# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :Regress
GirFFI.setup :Gio

describe GObject::Value do
  describe "::Struct" do
    let(:struct) { GObject::Value::Struct }

    it "has the members :g_type and :data" do
      _(struct.members).must_equal [:g_type, :data]
    end
  end

  describe ".for_gtype" do
    it "handles char" do
      gv = GObject::Value.for_gtype GObject::TYPE_CHAR
      _(gv.current_gtype).must_equal GObject::TYPE_CHAR
    end

    it "handles invalid type" do
      gv = GObject::Value.for_gtype GObject::TYPE_INVALID
      _(gv.current_gtype).must_equal GObject::TYPE_INVALID
    end

    it "handles void type" do
      gv = GObject::Value.for_gtype GObject::TYPE_NONE
      _(gv.current_gtype).must_equal GObject::TYPE_INVALID
    end
  end

  describe "::wrap_ruby_value" do
    it "wraps a boolean false" do
      gv = GObject::Value.wrap_ruby_value false

      assert_instance_of GObject::Value, gv
      _(gv.get_boolean).must_equal false
    end

    it "wraps a boolean true" do
      gv = GObject::Value.wrap_ruby_value true

      assert_instance_of GObject::Value, gv
      _(gv.get_boolean).must_equal true
    end

    it "wraps an Integer" do
      gv = GObject::Value.wrap_ruby_value 42
      _(gv.get_int).must_equal 42
    end

    it "wraps a String" do
      gv = GObject::Value.wrap_ruby_value "Some Random String"
      _(gv.get_string).must_equal "Some Random String"
    end

    it "wraps nil" do
      gv = GObject::Value.wrap_ruby_value nil

      assert_instance_of GObject::Value, gv
      _(gv.get_value).must_be_nil
    end

    it "wraps object values" do
      value = GObject::Object.new({})
      gv = GObject::Value.wrap_ruby_value value
      _(object_ref_count(value)).must_equal 2
      _(gv.get_value).must_equal value
      _(object_ref_count(value)).must_equal 3
    end
  end

  describe "#set_value" do
    it "handles signed char values" do
      value = -83
      gv = GObject::Value.for_gtype GObject::TYPE_CHAR
      gv.set_value value
      _(gv.get_schar).must_equal value
    end

    it "handles unsigned char values" do
      value = 174
      gv = GObject::Value.for_gtype GObject::TYPE_UCHAR
      gv.set_value value
      _(gv.get_uchar).must_equal value
    end

    it "handles enum values presented as symbols" do
      value = :value2
      gv = GObject::Value.for_gtype Regress::TestEnum.gtype
      gv.set_value value
      _(gv.get_value).must_equal value
    end

    it "handles enum values presented as numbers" do
      value = :value2
      gv = GObject::Value.for_gtype Regress::TestEnum.gtype
      gv.set_value Regress::TestEnum[value]
      _(gv.get_value).must_equal value
    end

    it "handles flag values presented as hashes" do
      value = { flag2: true }
      gv = GObject::Value.for_gtype Regress::TestFlags.gtype
      gv.set_value value
      _(gv.get_value).must_equal value
    end

    it "handles flag values presented as symbols" do
      gv = GObject::Value.for_gtype Regress::TestFlags.gtype
      gv.set_value :flag2
      _(gv.get_value).must_equal(flag2: true)
    end

    it "handles flag values presented as numbers" do
      value = { flag2: true }
      gv = GObject::Value.for_gtype Regress::TestFlags.gtype
      gv.set_value Regress::TestFlags.to_native(value, nil)
      _(gv.get_value).must_equal value
    end

    it "handles GType values" do
      value = GObject::TYPE_STRING
      gv = GObject::Value.for_gtype GObject::TYPE_GTYPE
      gv.set_value value
      _(gv.get_gtype).must_equal value
    end

    it "handles int64 values" do
      value = 0x1234_5678_9012_3456
      gv = GObject::Value.for_gtype GObject::TYPE_INT64
      gv.set_value value
      _(gv.get_int64).must_equal value
    end

    it "handles long values" do
      value = FFI.type_size(:long) == 8 ? 0x1234_5678_9012_3456 : 0x1234_5678
      gv = GObject::Value.for_gtype GObject::TYPE_LONG
      gv.set_value value
      _(gv.get_long).must_equal value
    end

    it "handles uchar values" do
      value = 83
      gv = GObject::Value.for_gtype GObject::TYPE_UCHAR
      gv.set_value value
      _(gv.get_uchar).must_equal value
    end

    it "handles uint values" do
      value = 0x1234_5678
      gv = GObject::Value.for_gtype GObject::TYPE_UINT
      gv.set_value value
      _(gv.get_uint).must_equal value
    end

    it "handles uint64 values" do
      value = 0x1234_5678_9012_3456
      gv = GObject::Value.for_gtype GObject::TYPE_UINT64
      gv.set_value value
      _(gv.get_uint64).must_equal value
    end

    it "handles ulong values" do
      value = FFI.type_size(:long) == 8 ? 0x1234_5678_9012_3456 : 0x1234_5678
      gv = GObject::Value.for_gtype GObject::TYPE_ULONG
      gv.set_value value
      _(gv.get_ulong).must_equal value
    end

    it "handles variant values" do
      value = GLib::Variant.new_string("Foo")
      gv = GObject::Value.for_gtype GObject::TYPE_VARIANT
      gv.set_value value
      _(gv.get_variant).must_equal value
    end

    it "handles object values" do
      value = GObject::Object.new({})
      gv = GObject::Value.for_gtype GObject::Object.gtype
      gv.set_value value
      _(gv.get_object).must_equal value
    end

    it "handles interface values" do
      value = Gio.file_new_for_path("/")
      gv = GObject::Value.for_gtype Gio::File.gtype
      gv.set_value value
      _(gv.get_object).must_equal value
    end
  end

  describe "#get_value" do
    it "unwraps a boolean false" do
      gv = GObject::Value.wrap_ruby_value false
      result = gv.get_value
      _(result).must_equal false
    end

    it "unwraps a boolean true" do
      gv = GObject::Value.wrap_ruby_value true
      result = gv.get_value
      _(result).must_equal true
    end

    it "unwraps a signed char" do
      value = -42
      gv = GObject::Value.for_gtype GObject::TYPE_CHAR
      gv.set_schar value
      _(gv.get_value).must_equal value
    end

    it "unwraps an unsigned char" do
      value = 173
      gv = GObject::Value.for_gtype GObject::TYPE_UCHAR
      gv.set_uchar value
      _(gv.get_value).must_equal value
    end

    it "unwraps an enum value" do
      value = :value2
      gv = GObject::Value.for_gtype Regress::TestEnum.gtype
      gv.set_enum Regress::TestEnum[value]
      _(gv.get_value).must_equal value
    end

    it "unwraps a flags value" do
      value = { flag1: true, flag3: true }
      gv = GObject::Value.for_gtype Regress::TestFlags.gtype
      gv.set_flags Regress::TestFlags.to_native(value, nil)
      _(gv.get_value).must_equal value
    end

    it "unwraps a GType" do
      value = GObject::TYPE_STRING
      gv = GObject::Value.for_gtype GObject::TYPE_GTYPE
      gv.set_gtype value
      _(gv.get_value).must_equal value
    end

    it "unwraps an int64" do
      value = 0x1234_5678_9012_3456
      gv = GObject::Value.for_gtype GObject::TYPE_INT64
      gv.set_int64 value
      _(gv.get_value).must_equal value
    end

    it "unwraps a long" do
      value = FFI.type_size(:long) == 8 ? 0x1234_5678_9012_3456 : 0x1234_5678
      gv = GObject::Value.for_gtype GObject::TYPE_LONG
      gv.set_long value
      _(gv.get_value).must_equal value
    end

    it "unwraps an uchar" do
      value = 3
      gv = GObject::Value.for_gtype GObject::TYPE_UCHAR
      gv.set_uchar value
      _(gv.get_value).must_equal value
    end

    it "unwraps an uint" do
      value = 0x1234_5678
      gv = GObject::Value.for_gtype GObject::TYPE_UINT
      gv.set_uint value
      _(gv.get_value).must_equal value
    end

    it "unwraps an uint64" do
      value = 0x1234_5678_9012_3456
      gv = GObject::Value.for_gtype GObject::TYPE_UINT64
      gv.set_uint64 value
      _(gv.get_value).must_equal value
    end

    it "unwraps an ulong" do
      value = FFI.type_size(:long) == 8 ? 0x1234_5678_9012_3456 : 0x1234_5678
      gv = GObject::Value.for_gtype GObject::TYPE_ULONG
      gv.set_ulong value
      _(gv.get_value).must_equal value
    end

    it "unwraps a variant" do
      value = GLib::Variant.new_string("Foo")
      gv = GObject::Value.for_gtype GObject::TYPE_VARIANT
      gv.set_variant value
      _(gv.get_value).must_equal value
    end

    it "works with a ByteArray" do
      ba = GLib::ByteArray.new.append("some bytes")
      v = GObject::Value.for_gtype GObject::TYPE_BYTE_ARRAY
      v.set_boxed ba

      result = v.get_value

      _(result.to_string).must_equal "some bytes"
      _(result).must_be_kind_of GLib::ByteArray
    end

    it "works with an Array" do
      arr = GLib::Array.from(:uint, [1, 2, 3])
      v = GObject::Value.for_gtype GObject::TYPE_ARRAY
      v.set_boxed arr

      result = v.get_value

      _(result).must_be_kind_of GLib::Array
      _(result.reset_typespec(:uint).to_a).must_equal [1, 2, 3]
    end

    it "unwraps a Strv" do
      strv = GLib::Strv.from %w[foo bar]
      val = GObject::Value.for_gtype GObject::TYPE_STRV
      val.set_boxed strv

      result = val.get_value

      _(result).must_be_kind_of GLib::Strv
      _(result.to_a).must_equal %w[foo bar]
    end
  end

  describe "::from" do
    it "creates a gint GValue from a Ruby Integer" do
      gv = GObject::Value.from 21
      _(gv.current_gtype_name).must_equal "gint"
      _(gv.get_value).must_equal 21
    end

    it "returns its argument if given a GValue" do
      gv = GObject::Value.from 21
      gv2 = GObject::Value.from gv
      _(gv2.current_gtype_name).must_equal "gint"
      _(gv2.get_value).must_equal 21
    end

    it "creates a null GValue from a Ruby nil" do
      gv = GObject::Value.from nil
      _(gv.current_gtype).must_equal GObject::TYPE_INVALID
      _(gv.get_value).must_be_nil
    end
  end

  describe "#set_value" do
    before do
      GirFFI.setup :GIMarshallingTests
    end

    it "raises an error when setting an incompatible object type" do
      o = GIMarshallingTests::Object.new 1
      v = GObject::Value.new.init(GIMarshallingTests::OverridesObject.gtype)
      _(proc { v.set_value o }).must_raise ArgumentError
    end

    it "works with a ByteArray" do
      ba = GLib::ByteArray.new.append("some bytes")
      v = GObject::Value.new.init(GObject.type_from_name("GByteArray"))
      v.set_value ba
      _(v.get_value.to_string).must_equal "some bytes"
    end
  end

  describe "#unset" do
    it "restores the underlying GValue to its pristine state" do
      value = GObject::Value.from 42

      _(value.current_gtype).must_equal GObject::TYPE_INT

      value.unset

      _(value.current_gtype).must_equal GObject::TYPE_INVALID
    end
  end

  describe "upon garbage collection" do
    it "frees the underlying GValue memory" do
      value = GObject::Value.from 42

      _(value.current_gtype).must_equal GObject::TYPE_INT

      GObject::Value.send :finalize, value.struct

      _(value.current_gtype).wont_equal GObject::TYPE_INT
    end

    it "drops refcount on contained objects" do
      obj = GObject::Object.new({})
      gv = GObject::Value.from obj

      _(object_ref_count(obj)).must_equal 2

      GObject::Value.send :finalize, gv.struct

      _(object_ref_count(obj)).must_equal 1
    end
  end
end
