# frozen_string_literal: true
#
# This section contains code that is needed by GObjectIntrospection and GirFFI,
# but belongs in modules that can only be created fully once GirFFI is fully
# loaded.

# GLib::Strv and GObject.type_init are needed by GObjectIntrospection
require 'gir_ffi-base/glib/strv'
require 'gir_ffi-base/gobject'

# GLib::Boolean is needed by GirFFI.
require 'gir_ffi-base/glib/boolean'
