#
# Based on the 'Hello world' Gtk+ tutorial example at
# http://library.gnome.org/devel/gtk-tutorial/2.90/c39.html#SEC-HELLOWORLD
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'gir_ffi'

GirFFI.setup :GObject
GirFFI.setup :Gtk

Gtk.init

win = Gtk::Window.new(:toplevel)
GObject.signal_connect_data win, "delete-event", FFI::Function.new(:bool, [:pointer, :pointer]) {
  puts "delete event occured"
  true
}, nil, nil, 0

GObject.signal_connect(win, "destroy") { Gtk.main_quit }
win.set_border_width 10

but = Gtk::Button.new_with_label("Hello World")
GObject.signal_connect(but, "clicked") { win.destroy }

win.add but

but.show
win.show

Gtk.main
