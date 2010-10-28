require 'forwardable'
module GirFFI
  # Base class for all generated classes. COntains code for dealing with
  # the generated Struct classes.
  class Base
    extend Forwardable
    def_delegators :@struct, :[], :[]=, :to_ptr

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
end
