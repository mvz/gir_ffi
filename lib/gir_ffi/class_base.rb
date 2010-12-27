require 'forwardable'
module GirFFI
  # Base class for all generated classes. Contains code for dealing with
  # the generated Struct classes.
  class ClassBase
    extend Forwardable
    def_delegators :@struct, :[], :[]=, :to_ptr

    def initialize(*args)
      # TODO: Handle NULL pointer.
      @struct = ffi_structure.new(*args)
    end

    def ffi_structure
      self.class.ffi_structure
    end

    def gir_ffi_builder
      self.class.gir_ffi_builder
    end

    def setup_and_call method, *arguments, &block
      result = gir_ffi_builder.setup_instance_method method.to_s
      return super unless result
      self.send method, *arguments, &block
    end

    def self.setup_and_call method, *arguments, &block
      result = gir_ffi_builder.setup_method method.to_s
      return super unless result
      self.send method, *arguments, &block
    end

    class << self
      def ffi_structure
	self.const_get(:Struct)
      end

      def gir_info
	self.const_get :GIR_INFO
      end

      def gir_ffi_builder
	self.const_get :GIR_FFI_BUILDER
      end

      alias_method :_real_new, :new
      undef new

      def wrap ptr
	return nil if ptr.nil? or ptr.null?
	_real_new ptr
      end

      def allocate
	_real_new
      end
    end
  end
end
