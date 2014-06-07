require 'forwardable'
require 'gir_ffi/builders/null_builder'
require 'gir_ffi/registered_type_base'

module GirFFI
  # Base class for all generated classes and structs. Contains code for dealing
  # with the generated nested Struct classes.
  class ClassBase
    extend RegisteredTypeBase
    extend Forwardable

    attr_reader :struct
    def_delegators :@struct, :to_ptr

    GIR_FFI_BUILDER = NullBuilder.new

    def setup_and_call method, *arguments, &block
      method_name = self.class.try_in_ancestors(:setup_instance_method, method.to_s)

      unless method_name
        raise RuntimeError, "Unable to set up instance method '#{method}' in #{self}"
      end

      send method_name, *arguments, &block
    end

    # FIXME: JRuby should fix FFI::MemoryPointer#== to return true for
    # equivalent FFI::Pointer. For now, user to_ptr.address
    def == other
      other.class == self.class && to_ptr.address == other.to_ptr.address
    end

    def self.setup_and_call method, *arguments, &block
      method_name = try_in_ancestors(:setup_method, method.to_s)

      unless method_name
        raise RuntimeError, "Unable to set up method '#{method}' in #{self}"
      end

      send method_name, *arguments, &block
    end

    def self.try_in_ancestors method, *arguments
      ancestors.each do |klass|
        if klass.respond_to?(method)
          result = klass.send(method, *arguments)
          return result if result
        end
      end
    end

    class << self
      def to_ffitype
        self::Struct
      end

      def setup_method name
        gir_ffi_builder.setup_method name
      end

      def setup_instance_method name
        gir_ffi_builder.setup_instance_method name
      end

      alias_method :_real_new, :new
      undef new

      # Wrap the passed pointer in an instance of the current class, or a
      # descendant type if applicable.
      def wrap ptr
        direct_wrap ptr
      end

      # Wrap the passed pointer in an instance of the current class. Will not
      # do any casting to subtypes.
      def direct_wrap ptr
        return nil if !ptr or ptr.null?
        obj = _real_new
        obj.instance_variable_set :@struct, self::Struct.new(ptr.to_ptr)
        obj
      end

      def _allocate
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

    #
    # Wraps a pointer retrieved from a constructor method. Here, it is simply
    # defined as a wrapper around direct_wrap, but, e.g., InitiallyUnowned
    # overrides it to sink the floating object.
    #
    # This method assumes the pointer will always be of the type corresponding
    # to the current class, and never of a subtype.
    #
    # @param ptr Pointer to the object's C structure
    #
    # @return An object of the current class wrapping the pointer
    #
    def self.constructor_wrap ptr
      direct_wrap ptr
    end
  end
end
