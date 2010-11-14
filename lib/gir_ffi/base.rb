require 'forwardable'
module GirFFI
  # Base class for all generated classes. Contains code for dealing with
  # the generated Struct classes.
  class Base
    extend Forwardable
    def_delegators :@struct, :[], :[]=, :to_ptr

    def initialize(*args)
      @struct = ffi_structure.new(*args)
    end

    def ffi_structure
      self.class.ffi_structure
    end

    private

    def method_name
      caller[0].gsub(/.*`(.*)'/, '\1')
    end

    class << self
      def ffi_structure
	self.const_get(:Struct)
      end
      alias_method :_real_new, :new
      undef new
    end
  end
end
