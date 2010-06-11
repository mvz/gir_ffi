#
# Based on the empty window Gtk+ tutorial example at
# http://library.gnome.org/devel/gtk-tutorial/2.90/c39.html
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'girffi'

GirFFI.setup :GObject
GirFFI.setup :Gtk

Gtk.init
win = Gtk::Window.new :toplevel
win.show
GObject.signal_connect_data win, "destroy", Proc.new { Gtk.main_quit }, nil, nil, 0
Gtk.main
