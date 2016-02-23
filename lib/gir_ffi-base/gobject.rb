# frozen_string_literal: true

# Ensure GLib is defined by GirFFI itself
raise 'The module GObject was already defined elsewhere' if Kernel.const_defined? :GObject

# The part of the GObject namespace that is needed by GObjectIntrospection.
module GObject
  def self.type_init
    Lib.g_type_init
  end
end

require 'gir_ffi-base/gobject/lib'
