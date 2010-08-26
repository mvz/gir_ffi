require 'ffi'
require 'forwardable'

class Foo < FFI::Struct
  layout :a, :int, :b, :int
end

class Bar < Foo
  layout :p, Foo, :c, :int
end

bar = Bar.new
bar[:p][:a] = 20
foo = Foo.new(bar.to_ptr)
puts foo[:a]

class Foo2
  extend Forwardable
  def_delegators :@struct, :[], :to_ptr
  class Struct < FFI::Struct
    layout :a, :int, :b, :int
  end
  def initialize(ptr=nil)
    @struct = Struct.new(ptr)
  end
end

class Bar2 < Foo2
  class Struct < FFI::Struct
    layout :p, Foo2::Struct, :c, :int
  end
  def initialize(ptr=nil)
    @struct = Struct.new(ptr)
  end
end

bar = Bar2.new
bar[:p][:a] = 20
foo = Foo2.new(bar.to_ptr)
puts foo[:a]
