require 'ffi'
require 'forwardable'

module Blub
  class Struct < FFI::Struct
    class << self
      def find_type(type, mod = nil)
	if type.kind_of?(Class) && type.const_defined?(:Struct)
	  super type.const_get(:Struct), mod
	else
	  super type, mod
	end
      end
    end
  end

  class Foo
    extend Forwardable
    def_delegators :@struct, :[], :to_ptr

    class Struct < Blub::Struct
      layout :a, :int, :b, :int
    end

    def initialize(ptr=nil)
      @struct = self.class.const_get(:Struct).new(ptr)
    end
  end

  class Bar < Foo
    class Struct < Blub::Struct
      layout :p, Foo, :c, :int
    end
  end
end

bar = Blub::Bar.new
bar[:p][:a] = 20
foo = Blub::Foo.new(bar.to_ptr)
puts foo[:a]
