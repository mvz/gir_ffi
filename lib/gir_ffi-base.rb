# frozen_string_literal: true
#
# This section contains code that is needed by GObjectIntrospection and GirFFI,
# but belongs in modules that can only be created fully once GirFFI is fully
# loaded.

# Some base GObject functions are needed by GirFFI.
require 'gir_ffi-base/gobject'
