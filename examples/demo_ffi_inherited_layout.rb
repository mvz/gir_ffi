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

