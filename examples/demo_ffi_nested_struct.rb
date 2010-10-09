# Demonstration program for FFI functionality.
#
# Basic demo of nested struct. Works in MRI, YARV, and JRuby. Does not work
# in Rubinius.
#
require 'ffi'

module LibTest
  class Foo < FFI::Struct
    layout :a, :int, :b, :int
  end

  class Bar < FFI::Struct
    layout :f, Foo, :g, :int
  end
end
puts LibTest::Bar.members.inspect
