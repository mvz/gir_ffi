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
