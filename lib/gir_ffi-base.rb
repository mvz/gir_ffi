# frozen_string_literal: true

#
# This section contains code that is needed by GirFFI, but belongs in modules
# that can only be created fully once GirFFI is fully loaded.

# Some base GObject functions and constants are needed by GirFFI.
require "gir_ffi-base/gobject"
