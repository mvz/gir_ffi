require 'forwardable'
module GirFFI
  # Base class for all generated classes. Contains code for dealing with
  # the generated Struct classes.
  class ClassBase
    # TODO: Make separate base for :struct, :union, :object.
    extend Forwardable
    def_delegators :@struct, :[], :[]=, :to_ptr

    def initialize(*args)
      @struct = ffi_structure.new(*args)
    end

    def ffi_structure
      self.class.ffi_structure
    end

    def _builder
      self.class._builder
    end

    def setup_and_call method, *arguments, &block
      unless _builder.setup_instance_method method.to_s
        raise RuntimeError, "Unable to set up instance method #{method} in #{self}"
      end
      self.send method, *arguments, &block
    end

    def self.setup_and_call method, *arguments, &block
      unless _builder.setup_method method.to_s
        raise RuntimeError, "Unable to set up method #{method} in #{self}"
      end
      self.send method, *arguments, &block
    end

    class << self
      def ffi_structure
	self.const_get(:Struct)
      end

      def gir_info
	self.const_get :GIR_INFO
      end

      def _builder
	self.const_get :GIR_FFI_BUILDER
      end

      def _find_signal name
        _builder.find_signal name
      end

      def _find_property name
        _builder.find_property name
      end

      def _setup_method name
        _builder.setup_method name
      end

      def _setup_instance_method name
        _builder.setup_instance_method name
      end

      alias_method :_real_new, :new
      undef new

      def wrap ptr
	return nil if ptr.nil? or ptr.null?
        unless ptr.is_a? FFI::Pointer
          ptr = ptr.to_ptr
        end
	_real_new ptr
      end

      # TODO: Only makes sense for :objects.
      def constructor_wrap ptr
        wrap ptr
      end

      def allocate
	_real_new
      end
    end
  end
end
