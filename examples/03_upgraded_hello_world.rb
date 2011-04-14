#
# Based on the 'Upgraded Hello world' Gtk+ tutorial example at
# http://library.gnome.org/devel/gtk-tutorial/2.90/x344.html
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'gir_ffi'

GirFFI.setup :Gtk, '2.0'

callback = lambda { |widget, data|
  puts "Hello again - #{data} was pressed"
}

Gtk.init

win = Gtk::Window.new(:toplevel)
win.set_title "Hello Buttons!"

GObject.signal_connect win, "delete-event" do
  Gtk.main_quit
  false
end

win.set_border_width 10

box = Gtk::HBox.new(false, 0)
win.add box

button = Gtk::Button.new_with_label("Button 1")
GObject.signal_connect button, "clicked", "button 1", &callback
box.pack_start button, true, true, 0
button.show

button = Gtk::Button.new_with_label("Button 2")
GObject.signal_connect button, "clicked", "button 2", &callback
box.pack_start button, true, true, 0
button.show

box.show
win.show

Gtk.main

