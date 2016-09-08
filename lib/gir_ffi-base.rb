# frozen_string_literal: true
#
# This section contains code that is needed by GObjectIntrospection and GirFFI,
# but belongs in modules that can only be created fully once GirFFI is fully
# loaded.

# GLib::Strv is needed by GObjectIntrospection
require 'gir_ffi-base/glib/strv'

# Some base GObject functions and GLib::Boolean are needed by GirFFI.
require 'gir_ffi-base/gobject'
require 'gir_ffi-base/glib/boolean'
