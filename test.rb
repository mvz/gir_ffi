require 'rubygems'
require 'ffi'
module Gtk
  extend FFI::Library

  ffi_lib "gtk-x11-2.0"
  attach_function :gtk_init, [:pointer, :pointer], :void
  attach_function :gtk_main, [], :void

  def self.init
    gtk_init nil, nil
  end

  class Window
    extend FFI::Library
    enum :GtkWindowType, [:GTK_WINDOW_TOPLEVEL, :GTK_WINDOW_POPUP]
    attach_function :gtk_window_new, [:GtkWindowType], :pointer
    attach_function :gtk_widget_show, [:pointer], :pointer

    def initialize type
      @gobj = gtk_window_new(type)
    end
    def show
      gtk_widget_show(@gobj)
    end
  end
end

#Gtk.gtk_init nil, nil
Gtk.init
win = Gtk::Window.new(:GTK_WINDOW_TOPLEVEL)
win.show
Gtk.gtk_main
