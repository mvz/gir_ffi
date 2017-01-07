# frozen_string_literal: true
require 'gir_ffi_test_helper'

require 'ffi-gobject'

GirFFI.setup :GIMarshallingTests

describe GObject do
  describe '.type_init' do
    it 'does not raise an error' do
      GObject.type_init
      pass
    end
  end

  it 'has constants for the fundamental GTypes' do
    GObject::TYPE_INVALID.must_equal GObject.type_from_name('invalid')
    GObject.type_name(GObject::TYPE_INVALID).must_be_nil

    GObject.type_name(GObject::TYPE_NONE).must_equal       'void'
    GObject.type_name(GObject::TYPE_INTERFACE).must_equal  'GInterface'
    GObject.type_name(GObject::TYPE_CHAR).must_equal       'gchar'
    GObject.type_name(GObject::TYPE_UCHAR).must_equal      'guchar'
    GObject.type_name(GObject::TYPE_BOOLEAN).must_equal    'gboolean'
    GObject.type_name(GObject::TYPE_INT).must_equal        'gint'
    GObject.type_name(GObject::TYPE_UINT).must_equal       'guint'
    GObject.type_name(GObject::TYPE_LONG).must_equal       'glong'
    GObject.type_name(GObject::TYPE_ULONG).must_equal      'gulong'
    GObject.type_name(GObject::TYPE_INT64).must_equal      'gint64'
    GObject.type_name(GObject::TYPE_UINT64).must_equal     'guint64'
    GObject.type_name(GObject::TYPE_ENUM).must_equal       'GEnum'
    GObject.type_name(GObject::TYPE_FLAGS).must_equal      'GFlags'
    GObject.type_name(GObject::TYPE_FLOAT).must_equal      'gfloat'
    GObject.type_name(GObject::TYPE_DOUBLE).must_equal     'gdouble'
    GObject.type_name(GObject::TYPE_STRING).must_equal     'gchararray'
    GObject.type_name(GObject::TYPE_POINTER).must_equal    'gpointer'
    GObject.type_name(GObject::TYPE_BOXED).must_equal      'GBoxed'
    GObject.type_name(GObject::TYPE_PARAM).must_equal      'GParam'
    GObject.type_name(GObject::TYPE_OBJECT).must_equal     'GObject'
    GObject.type_name(GObject::TYPE_GTYPE).must_equal      'GType'
    GObject.type_name(GObject::TYPE_VARIANT).must_equal    'GVariant'
    GObject.type_name(GObject::TYPE_STRV).must_equal       'GStrv'
    GObject.type_name(GObject::TYPE_HASH_TABLE).must_equal 'GHashTable'
  end

  describe '::object_class_from_instance' do
    it 'returns a GObject::ObjectClass with the correct GType' do
      obj = GIMarshallingTests::OverridesObject.new
      object_class = GObject.object_class_from_instance obj
      gtype = object_class.g_type_class.g_type

      object_class.must_be_instance_of GObject::ObjectClass
      gtype.must_equal GIMarshallingTests::OverridesObject.gtype
    end
  end

  describe 'creating ParamSpecs' do
    describe '#param_spec_int' do
      it 'creates a GObject::ParamSpecInt' do
        spec = GObject.param_spec_int('foo', 'foo bar',
                                      'The Foo Bar Property',
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
