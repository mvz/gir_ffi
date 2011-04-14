#
# Based on the empty window Gtk+ tutorial example at
# http://library.gnome.org/devel/gtk-tutorial/2.90/c39.html
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'gir_ffi'

GirFFI.setup :Gtk, '2.0'

Gtk.init
win = Gtk::Window.new :toplevel
win.show
GObject.signal_connect(win, "destroy") { Gtk.main_quit }
Gtk.main
