require 'ffi'
module Gtk
  extend FFI::Library

  ffi_lib "gtk-x11-2.0"
  attach_function :gtk_init, [:int, :pointer], :void
  attach_function :gtk_main, [], :void
  attach_function :gtk_main_quit, [], :void

  def self.init; gtk_init 0, nil; end
  def self.main; gtk_main; end
  def self.main_quit; gtk_main_quit; end

  class Widget
    extend FFI::Library
    attach_function :gtk_widget_show, [:pointer], :pointer

    callback :GCallback, [], :void
    enum :GConnectFlags, [:AFTER, (1<<0), :SWAPPED, (1<<1)]
    attach_function :g_signal_connect_data, [:pointer, :string, :GCallback,
      :pointer, :pointer, :GConnectFlags], :ulong

    @@callbacks = []

    def show
      gtk_widget_show(@gobj)
    end

    def signal_connect signal, data, &block
      prc = block.to_proc
      @@callbacks << prc
      g_signal_connect_data @gobj, signal, prc, data, nil, 0
    end
  end

  class Window < Widget
    enum :GtkWindowType, [:GTK_WINDOW_TOPLEVEL, :GTK_WINDOW_POPUP]
    attach_function :gtk_window_new, [:GtkWindowType], :pointer

    def initialize type
      @gobj = gtk_window_new(type)
    end
  end
end

#Gtk.gtk_init nil, nil
Gtk.init
win = Gtk::Window.new(:GTK_WINDOW_TOPLEVEL)
win.show
win.signal_connect("destroy", nil) { Gtk.main_quit }
Gtk.main
