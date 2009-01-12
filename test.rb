require 'rubygems'
require 'ffi'
module Gtk
  extend FFI::Library

  ffi_lib "gtk-x11-2.0"
  attach_function :gtk_init, [:pointer, :pointer], :void
  def self.init
    gtk_init nil, nil
  end
end

#Gtk.gtk_init nil, nil
Gtk.init
