#
# Based on the 'Upgraded Hello world' Gtk+ tutorial example at
# http://library.gnome.org/devel/gtk-tutorial/2.90/x344.html
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'girffi/builder'

GirFFI::Builder.build_module 'GObject'
GirFFI::Builder.build_module 'Gtk'
GirFFI::Builder.build_class 'Gtk', 'Window'
GirFFI::Builder.build_class 'Gtk', 'HBox'
GirFFI::Builder.build_class 'Gtk', 'Button'

# TODO: This is a little nasty, as we couldn't know from GIR that the
# second argument is a string here.
callback = FFI::Function.new(:void, [:pointer, :string]) do |widget, data|
  puts "Hello again - #{data} was pressed"
end

(my_len, my_args) = Gtk.init ARGV.length + 1, [$0, *ARGV]

win = Gtk::Window.new(:toplevel)
win.set_title "Hello Buttons!"

GObject.signal_connect_data win, "delete-event", FFI::Function.new(:bool, [:pointer, :pointer]) {
  Gtk.main_quit
  false
}, nil, nil, 0

win.set_border_width 10

box = Gtk::HBox.new(false, 0)
win.add box

button = Gtk::Button.new_with_label("Button 1")
GObject.signal_connect_data button, "clicked", callback, "button 1", nil, 0
box.pack_start button, true, true, 0
button.show

button = Gtk::Button.new_with_label("Button 2")
GObject.signal_connect_data button, "clicked", callback, "button 2", nil, 0
box.pack_start button, true, true, 0
button.show

box.show
win.show

Gtk.main

