require 'gir_ffi-base/gobject/lib'

# The part of the GObject namespace that is needed by GObjectIntrospection.
module GObject
  def self.type_init
    Lib::g_type_init
  end
end
