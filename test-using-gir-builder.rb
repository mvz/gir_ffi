# Test program using actual builder
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'girffi'
require 'girffi/builder'

builder = GirFFI::Builder.new
builder.build_module 'Gtk'
(my_len, my_args) = Gtk.init ARGV.length, ARGV
p my_len, my_args
Gtk.flub

