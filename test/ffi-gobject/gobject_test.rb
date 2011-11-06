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
    assert_equal GObject.type_from_name("void"), GObject::TYPE_NONE
    assert_equal GObject.type_from_name("GInterface"), GObject::TYPE_INTERFACE
    assert_equal GObject.type_from_name("gchar"), GObject::TYPE_CHAR
    assert_equal GObject.type_from_name("guchar"), GObject::TYPE_UCHAR
    assert_equal GObject.type_from_name("gboolean"), GObject::TYPE_BOOLEAN
    assert_equal GObject.type_from_name("gint"), GObject::TYPE_INT
    assert_equal GObject.type_from_name("guint"), GObject::TYPE_UINT
    assert_equal GObject.type_from_name("glong"), GObject::TYPE_LONG
    assert_equal GObject.type_from_name("gulong"), GObject::TYPE_ULONG
    assert_equal GObject.type_from_name("gint64"), GObject::TYPE_INT64
    assert_equal GObject.type_from_name("guint64"), GObject::TYPE_UINT64
    assert_equal GObject.type_from_name("GEnum"), GObject::TYPE_ENUM
    assert_equal GObject.type_from_name("GFlags"), GObject::TYPE_FLAGS
    assert_equal GObject.type_from_name("gfloat"), GObject::TYPE_FLOAT
    assert_equal GObject.type_from_name("gdouble"), GObject::TYPE_DOUBLE
    assert_equal GObject.type_from_name("gchararray"), GObject::TYPE_STRING
    assert_equal GObject.type_from_name("gpointer"), GObject::TYPE_POINTER
    assert_equal GObject.type_from_name("GBoxed"), GObject::TYPE_BOXED
    assert_equal GObject.type_from_name("GParam"), GObject::TYPE_PARAM
    assert_equal GObject.type_from_name("GObject"), GObject::TYPE_OBJECT
    assert_equal GObject.type_from_name("GType"), GObject::TYPE_GTYPE
    assert_equal GObject.type_from_name("GVariant"), GObject::TYPE_VARIANT
  end
end

