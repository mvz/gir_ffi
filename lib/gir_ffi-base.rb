# frozen_string_literal: true
# This section contains code that is needed by GObjectIntrospection, but
# belongs in modules that can only be created fully once GObjectIntrospection
# is fully loaded.
require 'gir_ffi-base/glib/boolean'
require 'gir_ffi-base/glib/strv'
require 'gir_ffi-base/gobject'
