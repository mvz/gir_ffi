require 'ffi-glib/container_class_methods'

module GLib
  # Common methods for List and SList.
  module ListMethods
    include Enumerable
    attr_reader :element_type

    def self.included(base)
      # Override default field accessors.
      replace_method base, :next, :tail
      replace_method base, :data, :head

      class << base; self end.send :remove_method, :new
      base.extend ListClassMethods

      base.extend ContainerClassMethods
    end

    def self.replace_method(base, old, new)
      base.class_eval do
        remove_method old
        alias_method old, new
      end
    end

    def each
      reset_iterator
      while (elem = next_element)
        yield elem
      end
    end

    def tail
      self.class.wrap(element_type, @struct[:next])
    end

    def head
      GirFFI::ArgHelper.cast_from_pointer(element_type, @struct[:data])
    end

    def reset_typespec(typespec)
      @element_type = typespec
      self
    end

    def ==(other)
      to_a == other.to_a
    end

    private

    def reset_iterator
      @current = self
    end

    def next_element
      return unless @current
      element = @current.head
      @current = @current.tail
      element
    end

    def element_ptr_for(data)
      GirFFI::InPointer.from(element_type, data)
    end

    # Common class methods for List and SList
    module ListClassMethods
      # TODO: Make this behave more like a real .new method
      def new(type)
        allocate.tap do |it|
          struct = self::Struct.new(FFI::Pointer.new(0))
          it.instance_variable_set :@struct, struct
          it.instance_variable_set :@element_type, type
        end
      end
    end
  end
end
