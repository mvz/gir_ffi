require 'forwardable'
require 'gir_ffi/builders/null_builder'
require 'gir_ffi/type_base'

module GirFFI
  # Base class for all generated classes. Contains code for dealing with
  # the generated Struct classes.
  class ClassBase
    extend TypeBase
    extend Forwardable

    def_delegators :@struct, :to_ptr

    GIR_FFI_BUILDER = NullBuilder.new

    def setup_and_call method, *arguments, &block
      method_name = self.class.try_in_ancestors(:setup_instance_method, method.to_s)

      unless method_name
        raise RuntimeError, "Unable to set up instance method '#{method}' in #{self}"
      end

      self.send method_name, *arguments, &block
    end

    if RUBY_PLATFORM == 'java'
      # FIXME: JRuby should fix FFI::MemoryPointer#== to return true for
      # equivalent FFI::Pointer.
      def ==(other)
        other.class == self.class && self.to_ptr.address == other.to_ptr.address
      end
    else
      def ==(other)
        other.class == self.class && self.to_ptr == other.to_ptr
      end
    end

    def self.setup_and_call method, *arguments, &block
      method_name = self.try_in_ancestors(:setup_method, method.to_s)

      unless method_name
        raise RuntimeError, "Unable to set up method '#{method}' in #{self}"
      end

      self.send method_name, *arguments, &block
    end

    def self.try_in_ancestors(method, *arguments)
      self.ancestors.each do |klass|
        if klass.respond_to?(method)
          result = klass.send(method, *arguments)
          return result if result
        end
      end
      return
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
  end
end
