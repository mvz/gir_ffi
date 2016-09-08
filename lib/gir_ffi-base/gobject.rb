# frozen_string_literal: true

# Ensure GObject is defined by GirFFI itself
raise 'The module GObject was already defined elsewhere' if Kernel.const_defined? :GObject

require 'gir_ffi-base/gobject/lib'

# The part of the GObject namespace that is needed by GObjectIntrospection.
#
# :reek:TooManyConstants: because it needs to hold the type constants.
module GObject
  def self.type_from_name(name)
    Lib.g_type_from_name name
  end

  def self.type_fundamental(gtype)
    Lib.g_type_fundamental gtype
  end

  TYPE_INVALID = type_from_name('invalid')
  TYPE_NONE = type_from_name('void')
  TYPE_INTERFACE = type_from_name('GInterface')
  TYPE_CHAR = type_from_name('gchar')
  TYPE_UCHAR = type_from_name('guchar')
  TYPE_BOOLEAN = type_from_name('gboolean')
  TYPE_INT = type_from_name('gint')
  TYPE_UINT = type_from_name('guint')
  TYPE_LONG = type_from_name('glong')
  TYPE_ULONG = type_from_name('gulong')
  TYPE_INT64 = type_from_name('gint64')
  TYPE_UINT64 = type_from_name('guint64')
  TYPE_ENUM = type_from_name('GEnum')
  TYPE_FLAGS = type_from_name('GFlags')
  TYPE_FLOAT = type_from_name('gfloat')
  TYPE_DOUBLE = type_from_name('gdouble')
  TYPE_STRING = type_from_name('gchararray')
  TYPE_POINTER = type_from_name('gpointer')
  TYPE_BOXED = type_from_name('GBoxed')
  TYPE_PARAM = type_from_name('GParam')
  TYPE_OBJECT = type_from_name('GObject')
  TYPE_GTYPE = type_from_name('GType')
  TYPE_VARIANT = type_from_name('GVariant')
end
