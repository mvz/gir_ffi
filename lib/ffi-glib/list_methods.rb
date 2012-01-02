require 'ffi-glib/container_class_methods'

module GLib
  module ListMethods
    include Enumerable
    attr_accessor :element_type

    def self.included base
      base.extend ContainerClassMethods
      # Override default field accessors.
      replace_method base, :next, :tail
      replace_method base, :data, :head
    end

    def self.replace_method base, old, new
      base.class_eval do
        remove_method old
        alias_method old, new
      end
    end

    def each
      list = self
      rval = nil
      until list.nil?
        rval = yield list.head
        list = list.tail
      end
      rval
    end

    def tail
      self.class.wrap(element_type, @struct[:next])
    end

    def head
      GirFFI::ArgHelper.cast_from_pointer(element_type, @struct[:data])
    end

    def reset_typespec typespec
      self.element_type = typespec
      self
    end
  end
end

