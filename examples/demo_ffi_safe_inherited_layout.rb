# Demonstrate safe inheritance with layout.
#
# Uses nested Struct class to separate inheritance from FFI::Struct from
# main inheritance structure. Works with MRI and JRuby, without warnings.

require 'ffi'
require 'forwardable'

module Blub
  class Foo
    extend Forwardable
    def_delegators :@struct, :[], :to_ptr

    class Struct < FFI::Struct
      layout :a, :int, :b, :int
    end

    def initialize(ptr=nil)
      @struct = ptr.nil? ?
	self.ffi_structure.new :
	self.ffi_structure.new(ptr)
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
    class Struct < FFI::Struct
      layout :p, Foo.ffi_structure, :c, :int
    end
  end
end

bar = Blub::Bar.new
bar[:p][:a] = 20
foo = Blub::Foo.new(bar.to_ptr)
puts foo[:a]
