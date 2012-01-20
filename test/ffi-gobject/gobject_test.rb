require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'ffi-gobject'

GirFFI.setup :GIMarshallingTests

class Sequence
  @@seq = 0
  def self.next
    @@seq += 1
  end
end

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

  describe "::define_type" do
    describe "without a block" do
      before do
        @klass = Class.new GIMarshallingTests::OverridesObject
        Object.const_set "Derived#{Sequence.next}", @klass
        @gtype = GObject.define_type @klass
      end

      it "returns a GType for the derived class" do
        parent_gtype = GIMarshallingTests::OverridesObject.get_gtype
        @gtype.wont_equal parent_gtype
        GObject.type_name(@gtype).must_equal @klass.name
      end

      it "makes #get_gtype on the registered class return the new GType" do
        @klass.get_gtype.must_equal @gtype
      end

      it "registers a type with the same size as the parent" do
        q = GObject.type_query @gtype
        q.instance_size.must_equal GIMarshallingTests::OverridesObject::Struct.size
      end

      it "creates a struct class for the derived class with just one member" do
        @klass::Struct.members.must_equal [:parent]
      end
    end

    describe "with a block with a call to #install_property" do
      before do
        @klass = Class.new GIMarshallingTests::OverridesObject
        Object.const_set "Derived#{Sequence.next}", @klass
        @gtype = GObject.define_type @klass do
          install_property GObject.param_spec_int("foo", "foo bar",
                                                  "The Foo Bar Property",
                                                  10, 20, 15,
                                                  3)
        end
      end

      it "registers a type that is bigger than the parent" do
        q = GObject.type_query @gtype
        q.instance_size.must_be :>, GIMarshallingTests::OverridesObject::Struct.size
      end

      it "gives the types Struct the fields :parent and :foo" do
        @klass::Struct.members.must_equal [:parent, :foo]
      end

      it "creates accessor functions for the property" do
        skip
        obj = @klass.new
        obj.foo = 13
        obj.foo.must_equal 13
      end
    end
  end
end
