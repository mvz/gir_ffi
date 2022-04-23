# frozen_string_literal: true

require "gir_ffi_test_helper"

require "ffi-gobject"

GirFFI.setup :GIMarshallingTests

describe GObject do
  describe ".type_init" do
    it "does not raise an error" do
      GObject.type_init
      pass
    end
  end

  it "has constants for the fundamental GTypes" do
    _(GObject::TYPE_INVALID).must_equal GObject.type_from_name("invalid")
    _(GObject.type_name(GObject::TYPE_INVALID)).must_be_nil

    _(GObject.type_name(GObject::TYPE_NONE)).must_equal       "void"
    _(GObject.type_name(GObject::TYPE_INTERFACE)).must_equal  "GInterface"
    _(GObject.type_name(GObject::TYPE_CHAR)).must_equal       "gchar"
    _(GObject.type_name(GObject::TYPE_UCHAR)).must_equal      "guchar"
    _(GObject.type_name(GObject::TYPE_BOOLEAN)).must_equal    "gboolean"
    _(GObject.type_name(GObject::TYPE_INT)).must_equal        "gint"
    _(GObject.type_name(GObject::TYPE_UINT)).must_equal       "guint"
    _(GObject.type_name(GObject::TYPE_LONG)).must_equal       "glong"
    _(GObject.type_name(GObject::TYPE_ULONG)).must_equal      "gulong"
    _(GObject.type_name(GObject::TYPE_INT64)).must_equal      "gint64"
    _(GObject.type_name(GObject::TYPE_UINT64)).must_equal     "guint64"
    _(GObject.type_name(GObject::TYPE_ENUM)).must_equal       "GEnum"
    _(GObject.type_name(GObject::TYPE_FLAGS)).must_equal      "GFlags"
    _(GObject.type_name(GObject::TYPE_FLOAT)).must_equal      "gfloat"
    _(GObject.type_name(GObject::TYPE_DOUBLE)).must_equal     "gdouble"
    _(GObject.type_name(GObject::TYPE_STRING)).must_equal     "gchararray"
    _(GObject.type_name(GObject::TYPE_POINTER)).must_equal    "gpointer"
    _(GObject.type_name(GObject::TYPE_BOXED)).must_equal      "GBoxed"
    _(GObject.type_name(GObject::TYPE_PARAM)).must_equal      "GParam"
    _(GObject.type_name(GObject::TYPE_OBJECT)).must_equal     "GObject"
    _(GObject.type_name(GObject::TYPE_GTYPE)).must_equal      "GType"
    _(GObject.type_name(GObject::TYPE_VARIANT)).must_equal    "GVariant"

    _(GObject.type_name(GObject::TYPE_ARRAY)).must_equal      "GArray"
    _(GObject.type_name(GObject::TYPE_BYTE_ARRAY)).must_equal "GByteArray"
    _(GObject.type_name(GObject::TYPE_ERROR)).must_equal      "GError"
    _(GObject.type_name(GObject::TYPE_HASH_TABLE)).must_equal "GHashTable"
    _(GObject.type_name(GObject::TYPE_STRV)).must_equal       "GStrv"
  end

  describe "::object_class_from_instance" do
    it "returns a GObject::ObjectClass with the correct GType" do
      obj = GIMarshallingTests::OverridesObject.new
      class_struct = GObject.object_class_from_instance obj
      gtype = class_struct.g_type_class.g_type

      _(class_struct).must_be_instance_of GObject::ObjectClass
      _(gtype).must_equal GIMarshallingTests::OverridesObject.gtype
    end
  end

  describe "creating ParamSpecs" do
    describe "#param_spec_int" do
      it "creates a GObject::ParamSpecInt" do
        spec = GObject.param_spec_int("foo", "foo bar",
                                      "The Foo Bar Property",
                                      10, 20, 15,
                                      3)
        _(spec).must_be_instance_of GObject::ParamSpecInt
        _(spec.struct[:minimum]).must_equal 10
        _(spec.struct[:maximum]).must_equal 20
        _(spec.get_default_value).must_equal 15
      end
    end
  end
end
