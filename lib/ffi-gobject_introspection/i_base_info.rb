# frozen_string_literal: true

module GObjectIntrospection
  # Wraps GIBaseInfo struct, the base \type for all info types.
  # Decendant types will be implemented as needed.
  class IBaseInfo
    def initialize(ptr, lib = Lib)
      raise ArgumentError, "ptr must not be null" if ptr.null?

      ObjectSpace.define_finalizer self, self.class.make_finalizer(lib, ptr)

      @pointer = ptr
      @lib = lib
    end

    attr_reader :pointer

    def self.make_finalizer(lib, ptr)
      proc { lib.g_base_info_unref ptr }
    end

    def to_ptr
      @pointer
    end

    # This is a helper method to construct a method returning an array, out
    # of the methods returning their number and the individual elements.
    #
    # For example, given the methods +n_foos+ and +foo+(+i+), this method
    # will create an additional method +foos+ returning all foos.
    #
    # Provide the second parameter if the plural is not trivially
    # constructed by adding +s+ to the singular.
    #
    # Examples:
    #
    #   build_array_method :fields
    #   build_array_mehtod :properties, :property
    #   build_array_method :get_methods
    #
    def self.build_array_method(method, single = nil)
      method = method.to_s
      single ||= method[0..-2]
      count = method.sub(/^(get_)?/, '\\1n_')
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{method}
          (0..(#{count} - 1)).map do |i|
            #{single} i
          end
        end
      CODE
    end

    # This is a helper method to construct a method for finding an element, out
    # of the methods returning their number and the individual elements.
    #
    # For example, given the methods +n_foos+ and +foo+(+i+), this method will
    # create an additional method +find_foo+ returning the foo with the
    # matching name.
    #
    # Optionally provide counter and fetcher methods if they cannot be
    # trivially derived from the finder method.
    #
    # Examples:
    #
    #   build_finder_method :find_field
    #   build_finder_method :find_property, :n_properties
    #   build_finder_method :find_method, :get_n_methods, :get_method
    #
    def self.build_finder_method(method, counter = nil, fetcher = nil)
      method = method.to_s
      single = method.sub(/^find_/, "")
      counter ||= "n_#{single}s"
      fetcher ||= single
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{method}(name)
          name = name.to_s
          #{counter}.times do |i|
            it = #{fetcher}(i)
            return it if it.name == name
          end
          nil
        end
      CODE
    end

    def name
      Lib.g_base_info_get_name self
    end

    def info_type
      Lib.g_base_info_get_type self
    end

    def namespace
      Lib.g_base_info_get_namespace self
    end

    def safe_namespace
      namespace.gsub(/^./, &:upcase)
    end

    def container
      ptr = Lib.g_base_info_get_container self
      Lib.g_base_info_ref ptr
      IRepository.wrap_ibaseinfo_pointer ptr
    end

    def deprecated?
      Lib.g_base_info_is_deprecated self
    end

    def attribute(name)
      Lib.g_base_info_get_attribute self, name
    end

    def self.wrap(ptr)
      new ptr unless ptr.null?
    end

    def ==(other)
      other.is_a?(IBaseInfo) && Lib.g_base_info_equal(self, other)
    end
  end
end
