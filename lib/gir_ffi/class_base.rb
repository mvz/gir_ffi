require 'forwardable'
require 'gir_ffi/ffi_ext/pointer'

module GirFFI
  # Base class for all generated classes. Contains code for dealing with
  # the generated Struct classes.
  class ClassBase
    # TODO: Make separate base for :struct, :union, :object.
    extend Forwardable
    def_delegators :@struct, :to_ptr

    def setup_and_call method, *arguments, &block
      result = self.class.ancestors.any? do |klass|
        klass.respond_to?(:_setup_instance_method) &&
          klass._setup_instance_method(method.to_s)
      end

      unless result
        raise RuntimeError, "Unable to set up instance method #{method} in #{self}"
      end

      self.send method, *arguments, &block
    end

    def self.setup_and_call method, *arguments, &block
      result = self.ancestors.any? do |klass|
        klass.respond_to?(:_setup_method) &&
          klass._setup_method(method.to_s)
      end

      unless result
        raise RuntimeError, "Unable to set up method #{method} in #{self}"
      end

      self.send method, *arguments, &block
    end

    class << self
      # @deprecated Compatibility function. Remove in version 0.5.0.
      def ffi_structure
        self::Struct
      end

      def gir_info
        self.const_get :GIR_INFO
      end

      # @deprecated Compatibility function. Remove in version 0.5.0.
      def _builder
        gir_ffi_builder
      end

      def gir_ffi_builder
        self.const_get :GIR_FFI_BUILDER
      end

      # @deprecated Compatibility function. Remove in version 0.5.0.
      def _setup_method name
        setup_method name
      end

      def setup_method name
        _builder.setup_method name
      end

      # @deprecated Compatibility function. Remove in version 0.5.0.
      def _setup_instance_method name
        setup_instance_method name
      end

      def setup_instance_method name
        _builder.setup_instance_method name
      end

      alias_method :_real_new, :new
      undef new

      def wrap ptr
        return nil if ptr.nil? or ptr.null?
        obj = _real_new
        obj.instance_variable_set :@struct, self::Struct.new(ptr.to_ptr)
        obj
      end

      def allocate
        obj = _real_new
        obj.instance_variable_set :@struct, self::Struct.new
        obj
      end

      # Pass-through casting method. This may become a type checking
      # method. It is overridden by GValue to implement wrapping of plain
      # Ruby objects.
      def from val
        val
      end
    end
  end
end
