# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :Everything

describe Everything do
  it 'has a working function #const_return_GType' do
    _(Everything.const_return_GType).must_equal GObject::TYPE_OBJECT
  end

  it 'has a working function #const_return_filename' do
    _(Everything.const_return_filename).must_equal ''
  end

  it 'has a working function #const_return_gboolean' do
    _(Everything.const_return_gboolean).must_equal false
  end

  it 'has a working function #const_return_gchar' do
    _(Everything.const_return_gchar).must_equal 0
  end

  it 'has a working function #const_return_gdouble' do
    _(Everything.const_return_gdouble).must_equal 0
  end

  it 'has a working function #const_return_gfloat' do
    _(Everything.const_return_gfloat).must_equal 0
  end

  it 'has a working function #const_return_gint' do
    _(Everything.const_return_gint).must_equal 0
  end

  it 'has a working function #const_return_gint16' do
    _(Everything.const_return_gint16).must_equal 0
  end

  it 'has a working function #const_return_gint32' do
    _(Everything.const_return_gint32).must_equal 0
  end

  it 'has a working function #const_return_gint64' do
    _(Everything.const_return_gint64).must_equal 0
  end

  it 'has a working function #const_return_gint8' do
    _(Everything.const_return_gint8).must_equal 0
  end

  it 'has a working function #const_return_gintptr' do
    _(Everything.const_return_gintptr).must_equal 0
  end

  it 'has a working function #const_return_glong' do
    _(Everything.const_return_glong).must_equal 0
  end

  it 'has a working function #const_return_gpointer' do
    unless get_introspection_data 'Everything', 'const_return_gpointer'
      skip 'Introduced in 1.47.1'
    end
    _(Everything.const_return_gpointer).must_be :null?
  end

  it 'has a working function #const_return_gshort' do
    _(Everything.const_return_gshort).must_equal 0
  end

  it 'has a working function #const_return_gsize' do
    _(Everything.const_return_gsize).must_equal 0
  end

  it 'has a working function #const_return_gssize' do
    _(Everything.const_return_gssize).must_equal 0
  end

  it 'has a working function #const_return_guint' do
    _(Everything.const_return_guint).must_equal 0
  end

  it 'has a working function #const_return_guint16' do
    _(Everything.const_return_guint16).must_equal 0
  end

  it 'has a working function #const_return_guint32' do
    _(Everything.const_return_guint32).must_equal 0
  end

  it 'has a working function #const_return_guint64' do
    _(Everything.const_return_guint64).must_equal 0
  end

  it 'has a working function #const_return_guint8' do
    _(Everything.const_return_guint8).must_equal 0
  end

  it 'has a working function #const_return_guintptr' do
    _(Everything.const_return_guintptr).must_equal 0
  end

  it 'has a working function #const_return_gulong' do
    _(Everything.const_return_gulong).must_equal 0
  end

  it 'has a working function #const_return_gunichar' do
    _(Everything.const_return_gunichar).must_equal 0
  end

  it 'has a working function #const_return_gushort' do
    _(Everything.const_return_gushort).must_equal 0
  end

  it 'has a working function #const_return_utf8' do
    _(Everything.const_return_utf8).must_equal ''
  end

  it 'has a working function #nullfunc' do
    _(Everything.nullfunc).must_be_nil
  end

  it 'has a working function #one_outparam_GType' do
    _(Everything.one_outparam_GType).must_equal 0
  end

  it 'has a working function #one_outparam_filename' do
    # NOTE: This function stores a null pointer in its output parameter.
    _(Everything.one_outparam_filename).must_be_nil
  end

  it 'has a working function #one_outparam_gboolean' do
    _(Everything.one_outparam_gboolean).must_equal false
  end

  it 'has a working function #one_outparam_gchar' do
    skip 'GIR gives the incorrect type: utf8 instead of gchar'
    _(Everything.one_outparam_gchar).must_equal 0
  end

  it 'has a working function #one_outparam_gdouble' do
    _(Everything.one_outparam_gdouble).must_equal 0
  end

  it 'has a working function #one_outparam_gfloat' do
    _(Everything.one_outparam_gfloat).must_equal 0
  end

  it 'has a working function #one_outparam_gint' do
    _(Everything.one_outparam_gint).must_equal 0
  end

  it 'has a working function #one_outparam_gint16' do
    _(Everything.one_outparam_gint16).must_equal 0
  end

  it 'has a working function #one_outparam_gint32' do
    _(Everything.one_outparam_gint32).must_equal 0
  end

  it 'has a working function #one_outparam_gint64' do
    _(Everything.one_outparam_gint64).must_equal 0
  end

  it 'has a working function #one_outparam_gint8' do
    _(Everything.one_outparam_gint8).must_equal 0
  end

  it 'has a working function #one_outparam_gintptr' do
    _(Everything.one_outparam_gintptr).must_equal 0
  end

  it 'has a working function #one_outparam_glong' do
    _(Everything.one_outparam_glong).must_equal 0
  end

  it 'has a working function #one_outparam_gpointer' do
    unless get_introspection_data 'Everything', 'one_outparam_gpointer'
      skip 'Introduced in 1.47.1'
    end
    _(Everything.one_outparam_gpointer).must_be :null?
  end

  it 'has a working function #one_outparam_gshort' do
    _(Everything.one_outparam_gshort).must_equal 0
  end

  it 'has a working function #one_outparam_gsize' do
    _(Everything.one_outparam_gsize).must_equal 0
  end

  it 'has a working function #one_outparam_gssize' do
    _(Everything.one_outparam_gssize).must_equal 0
  end

  it 'has a working function #one_outparam_guint' do
    _(Everything.one_outparam_guint).must_equal 0
  end

  it 'has a working function #one_outparam_guint16' do
    _(Everything.one_outparam_guint16).must_equal 0
  end

  it 'has a working function #one_outparam_guint32' do
    _(Everything.one_outparam_guint32).must_equal 0
  end

  it 'has a working function #one_outparam_guint64' do
    _(Everything.one_outparam_guint64).must_equal 0
  end

  it 'has a working function #one_outparam_guint8' do
    _(Everything.one_outparam_guint8).must_equal 0
  end

  it 'has a working function #one_outparam_guintptr' do
    _(Everything.one_outparam_guintptr).must_equal 0
  end

  it 'has a working function #one_outparam_gulong' do
    _(Everything.one_outparam_gulong).must_equal 0
  end

  it 'has a working function #one_outparam_gunichar' do
    _(Everything.one_outparam_gunichar).must_equal 0
  end

  it 'has a working function #one_outparam_gushort' do
    _(Everything.one_outparam_gushort).must_equal 0
  end

  it 'has a working function #one_outparam_utf8' do
    # NOTE: This function stores a null pointer in its output parameter.
    _(Everything.one_outparam_utf8).must_be_nil
  end

  it 'has a working function #oneparam_GType' do
    _(Everything.oneparam_GType(0)).must_be_nil
  end

  it 'has a working function #oneparam_filename' do
    _(Everything.oneparam_filename('')).must_be_nil
  end

  it 'has a working function #oneparam_gboolean' do
    _(Everything.oneparam_gboolean(false)).must_be_nil
  end

  it 'has a working function #oneparam_gchar' do
    _(Everything.oneparam_gchar(0)).must_be_nil
  end

  it 'has a working function #oneparam_gdouble' do
    _(Everything.oneparam_gdouble(0.0)).must_be_nil
  end

  it 'has a working function #oneparam_gfloat' do
    _(Everything.oneparam_gfloat(0.0)).must_be_nil
  end

  it 'has a working function #oneparam_gint' do
    _(Everything.oneparam_gint(0)).must_be_nil
  end

  it 'has a working function #oneparam_gint16' do
    _(Everything.oneparam_gint16(0)).must_be_nil
  end

  it 'has a working function #oneparam_gint32' do
    _(Everything.oneparam_gint32(0)).must_be_nil
  end

  it 'has a working function #oneparam_gint64' do
    _(Everything.oneparam_gint64(0)).must_be_nil
  end

  it 'has a working function #oneparam_gint8' do
    _(Everything.oneparam_gint8(0)).must_be_nil
  end

  it 'has a working function #oneparam_gintptr' do
    _(Everything.oneparam_gintptr(0)).must_be_nil
  end

  it 'has a working function #oneparam_glong' do
    _(Everything.oneparam_glong(0)).must_be_nil
  end

  it 'has a working function #oneparam_gpointer' do
    skip 'Introduced in 1.47.1' unless get_introspection_data 'Everything', 'oneparam_gpointer'
    _(Everything.oneparam_gpointer(FFI::MemoryPointer.new(:int))).must_be_nil
  end

  it 'has a working function #oneparam_gshort' do
    _(Everything.oneparam_gshort(0)).must_be_nil
  end

  it 'has a working function #oneparam_gsize' do
    _(Everything.oneparam_gsize(0)).must_be_nil
  end

  it 'has a working function #oneparam_gssize' do
    _(Everything.oneparam_gssize(0)).must_be_nil
  end

  it 'has a working function #oneparam_guint' do
    _(Everything.oneparam_guint(0)).must_be_nil
  end

  it 'has a working function #oneparam_guint16' do
    _(Everything.oneparam_guint16(0)).must_be_nil
  end

  it 'has a working function #oneparam_guint32' do
    _(Everything.oneparam_guint32(0)).must_be_nil
  end

  it 'has a working function #oneparam_guint64' do
    _(Everything.oneparam_guint64(0)).must_be_nil
  end

  it 'has a working function #oneparam_guint8' do
    _(Everything.oneparam_guint8(0)).must_be_nil
  end

  it 'has a working function #oneparam_guintptr' do
    _(Everything.oneparam_guintptr(0)).must_be_nil
  end

  it 'has a working function #oneparam_gulong' do
    _(Everything.oneparam_gulong(0)).must_be_nil
  end

  it 'has a working function #oneparam_gunichar' do
    _(Everything.oneparam_gunichar(0)).must_be_nil
  end

  it 'has a working function #oneparam_gushort' do
    _(Everything.oneparam_gushort(0)).must_be_nil
  end

  it 'has a working function #oneparam_utf8' do
    _(Everything.oneparam_utf8('')).must_be_nil
  end

  it 'has a working function #passthrough_one_GType' do
    _(Everything.passthrough_one_GType(GObject::TYPE_OBJECT)).must_equal GObject::TYPE_OBJECT
  end

  it 'has a working function #passthrough_one_filename' do
    _(Everything.passthrough_one_filename('foo')).must_equal 'foo'
  end

  it 'has a working function #passthrough_one_gboolean' do
    _(Everything.passthrough_one_gboolean(true)).must_equal true
  end

  it 'has a working function #passthrough_one_gchar' do
    _(Everything.passthrough_one_gchar(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gdouble' do
    _(Everything.passthrough_one_gdouble(23.42)).must_equal 23.42
  end

  it 'has a working function #passthrough_one_gfloat' do
    _(Everything.passthrough_one_gfloat(23.42)).must_be_close_to 23.42
  end

  it 'has a working function #passthrough_one_gint' do
    _(Everything.passthrough_one_gint(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gint16' do
    _(Everything.passthrough_one_gint16(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gint32' do
    _(Everything.passthrough_one_gint32(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gint64' do
    _(Everything.passthrough_one_gint64(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gint8' do
    _(Everything.passthrough_one_gint8(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gintptr' do
    _(Everything.passthrough_one_gintptr(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_glong' do
    _(Everything.passthrough_one_glong(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gpointer' do
    unless get_introspection_data 'Everything', 'passthrough_one_gpointer'
      skip 'Introduced in 1.47.1'
    end
    ptr = FFI::MemoryPointer.new(:int)
    result = Everything.passthrough_one_gpointer(ptr)
    _(result).must_be :==, ptr
  end

  it 'has a working function #passthrough_one_gshort' do
    _(Everything.passthrough_one_gshort(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gsize' do
    _(Everything.passthrough_one_gsize(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gssize' do
    _(Everything.passthrough_one_gssize(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_guint' do
    _(Everything.passthrough_one_guint(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_guint16' do
    _(Everything.passthrough_one_guint16(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_guint32' do
    _(Everything.passthrough_one_guint32(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_guint64' do
    _(Everything.passthrough_one_guint64(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_guint8' do
    _(Everything.passthrough_one_guint8(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_guintptr' do
    _(Everything.passthrough_one_guintptr(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gulong' do
    _(Everything.passthrough_one_gulong(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gunichar' do
    _(Everything.passthrough_one_gunichar(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_gushort' do
    _(Everything.passthrough_one_gushort(42)).must_equal 42
  end

  it 'has a working function #passthrough_one_utf8' do
    _(Everything.passthrough_one_utf8('42')).must_equal '42'
  end
end
