require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'ffi-gobject'

describe GObject do
  it "has type_init as a public method" do
    assert GObject.respond_to?('type_init')
  end

  it "does not have g_type_init as a public method" do
    assert GObject.respond_to?('g_type_init') == false
  end

  context "::type_init" do
    it "does not raise an error" do
      assert_nothing_raised do
        GObject.type_init
      end
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
end

