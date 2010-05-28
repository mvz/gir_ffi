$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'girffi/builder'

GirFFI::Builder.build_module 'GObject'
GirFFI::Builder.build_module 'Gtk'
GirFFI::Builder.build_class 'Gtk', 'Window'

(my_len, my_args) = Gtk.init ARGV.length + 1, [$0, *ARGV]
win = Gtk::Window.new(:toplevel)
win.show
GObject.signal_connect_data win, "destroy", Proc.new { Gtk.main_quit }, nil, nil, 0
Gtk.main
