# Test program using actual builder
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'girffi/builder'

builder = GirFFI::Builder.new
builder.build_module 'Gtk', 'Foo'
(my_len, my_args) = Foo::Gtk.init ARGV.length, ARGV
p my_len, my_args
Foo::Gtk.flub

