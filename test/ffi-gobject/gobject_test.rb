require 'gir_ffi_test_helper'

require 'ffi-gobject'

GirFFI.setup :GIMarshallingTests

describe GObject do
  describe ".type_init" do
    it "does not raise an error" do
      GObject.type_init
      pass
    end
  end

  it "has constants for the fundamental GTypes" do
    assert_equal GObject.type_from_name("invalid"), GObject::TYPE_INVALID
    assert_equal nil, GObject.type_name(GObject::TYPE_INVALID)

    assert_equal "void", GObject.type_name(GObject::TYPE_NONE)
    assert_equal "GInterface", GObject.type_name(GObject::TYPE_INTERFACE)
    assert_equal "gchar", GObject.type_name(GObject::TYPE_CHAR)
    assert_equal "guchar", GObject.type_name(GObject::TYPE_UCHAR)
    assert_equal "gboolean", GObject.type_name(GObject::TYPE_BOOLEAN)
    assert_equal "gint", GObject.type_name(GObject::TYPE_INT)
    assert_equal "guint", GObject.type_name(GObject::TYPE_UINT)
    assert_equal "glong", GObject.type_name(GObject::TYPE_LONG)
    assert_equal "gulong", GObject.type_name(GObject::TYPE_ULONG)
    assert_equal "gint64", GObject.type_name(GObject::TYPE_INT64)
    assert_equal "guint64", GObject.type_name(GObject::TYPE_UINT64)
    assert_equal "GEnum", GObject.type_name(GObject::TYPE_ENUM)
    assert_equal "GFlags", GObject.type_name(GObject::TYPE_FLAGS)
    assert_equal "gfloat", GObject.type_name(GObject::TYPE_FLOAT)
    assert_equal "gdouble", GObject.type_name(GObject::TYPE_DOUBLE)
    assert_equal "gchararray", GObject.type_name(GObject::TYPE_STRING)
    assert_equal "gpointer", GObject.type_name(GObject::TYPE_POINTER)
    assert_equal "GBoxed", GObject.type_name(GObject::TYPE_BOXED)
    assert_equal "GParam", GObject.type_name(GObject::TYPE_PARAM)
    assert_equal "GObject", GObject.type_name(GObject::TYPE_OBJECT)
    assert_equal "GType", GObject.type_name(GObject::TYPE_GTYPE)
    assert_equal "GVariant", GObject.type_name(GObject::TYPE_VARIANT)
    assert_equal "GStrv", GObject.type_name(GObject::TYPE_STRV)
    assert_equal "GHashTable", GObject.type_name(GObject::TYPE_HASH_TABLE)
  end

  describe "::object_class_from_instance" do
    it "returns a GObject::ObjectClass with the correct GType" do
      obj = GIMarshallingTests::OverridesObject.new
      object_class = GObject.object_class_from_instance obj
      gtype = object_class.g_type_class.g_type

      object_class.must_be_instance_of GObject::ObjectClass
      gtype.must_equal GIMarshallingTests::OverridesObject.get_gtype
    end
  end

  describe "creating ParamSpecs" do
    describe "#param_spec_int" do
      it "creates a GObject::ParamSpecInt" do
        spec = GObject.param_spec_int("foo", "foo bar",
                                      "The Foo Bar Property",
                                      10, 20, 15,
                                      3)
        spec.must_be_instance_of GObject::ParamSpecInt
        spec.minimum.must_equal 10
        spec.maximum.must_equal 20
        spec.default_value.must_equal 15
      end
    end
  end
end
