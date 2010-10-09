# Demonstration program for FFI functionality.
#
# Show what happens if we call layout again in a subclass. This works in
# JRuby, but not in MRI (gives warnings with ffi 0.6.3, is explicitely
# forbidden later).
#
require 'ffi'

class Foo < FFI::Struct
  layout :a, :int, :b, :int
end

class Bar < Foo
  layout :p, Foo, :c, :int
end

bar = Bar.new
foo = Foo.new(bar.to_ptr)
foo[:a] = 20
puts "bar[:p][:a] = #{bar[:p][:a]}"

