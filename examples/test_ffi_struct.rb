require 'ffi'
require 'forwardable'

module Blub
  class Struct < FFI::Struct
    class << self
      def find_type(type, mod = nil)
	if type.respond_to?(:ffi_structure)
	  super type.ffi_structure, mod
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
      @struct = self.ffi_structure.new(ptr)
    end

    def ffi_structure
      self.class.ffi_structure
    end

    class << self
      def ffi_structure
	self.const_get(:Struct)
      end
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
