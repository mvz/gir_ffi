# frozen_string_literal: true
# This section contains code that is needed by GObjectIntrospection, but
# belongs in modules that can only be created fully once GObjectIntrospection
# is fully loaded.

# FIXME: GLib::Boolean is not needed by GObjectIntrospection, but by GirFFI.
require 'gir_ffi-base/glib/boolean'

# TODO: Require these where they are needed
require 'gir_ffi-base/glib/strv'
require 'gir_ffi-base/gobject'
