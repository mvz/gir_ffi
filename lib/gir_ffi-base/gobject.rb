require 'gir_ffi-base/gobject/lib'

module GObject
  def self.type_init
    Lib::g_type_init
  end
end
