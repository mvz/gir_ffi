#
# Straight port from 'Hello world' Gtk+ tutorial example.
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'girffi/builder'

builder = GirFFI::Builder.new
builder.build_module 'GObject'
builder.build_module 'Gtk'
builder.build_class 'Gtk', 'Window'
builder.build_class 'Gtk', 'Button'
builder.build_class 'Gtk', 'Label'

(my_len, my_args) = Gtk.init ARGV.length + 1, [$0, *ARGV]

win = Gtk::Window.new(:toplevel)
GObject.signal_connect_data(win, "delete-event", nil, nil, 0) {
  puts "delete event occured"
  # TODO: Return value is not passed on by ffi.
  true
}
GObject.signal_connect_data(win, "destroy", nil, nil, 0) { Gtk.main_quit }
win.set_border_width 10

# TODO: Make new_with_label work.
(but = Gtk::Button.new).add(lbl = Gtk::Label.new("Hello World"))
GObject.signal_connect_data(but, "clicked", nil, nil, :swapped) { win.destroy }

win.add but

lbl.show
but.show
win.show

Gtk.main
