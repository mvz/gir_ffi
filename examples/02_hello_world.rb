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
GObject.signal_connect_data win, "delete-event", FFI::Function.new(:bool, [:pointer, :pointer]) {
  puts "delete event occured"
  true
}, nil, nil, 0

GObject.signal_connect_data win, "destroy", Proc.new { Gtk.main_quit }, nil, nil, 0
win.set_border_width 10

but = Gtk::Button.new_with_label("Hello World")
GObject.signal_connect_data but, "clicked", Proc.new { win.destroy }, nil, nil, :swapped

win.add but

but.show
win.show

Gtk.main
