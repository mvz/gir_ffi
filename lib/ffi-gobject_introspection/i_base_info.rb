module GObjectIntrospection
  # Wraps GIBaseInfo struct, the base \type for all info types.
  # Decendant types will be implemented as needed.
  class IBaseInfo
    def initialize ptr, lib=Lib
      raise ArgumentError, "ptr must not be null" if ptr.null?

      unless defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
        ObjectSpace.define_finalizer self, self.class.make_finalizer(lib, ptr)
      end

      @gobj = ptr
      @lib = lib
    end

    def self.make_finalizer lib, ptr
      proc { lib.g_base_info_unref ptr }
    end

    def to_ptr
      @gobj
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
    def self.build_array_method method, single = nil
      method = method.to_s
      single ||= method.to_s[0..-2]
      count = method.sub(/^(get_)?/, "\\1n_")
      self.class_eval <<-CODE
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
    # Provide the second parameter if the plural is not trivially
    # constructed by adding +s+ to the singular.
    #
    # Examples:
    #
    #   build_finder_method :find_field
    #   build_finder_mehtod :find_property, :properties
    #
    def self.build_finder_method method, plural = nil
      method = method.to_s
      single = method.sub(/^find_/, "")
      plural ||= "#{single}s"
      count ||= "n_#{plural}"
      self.class_eval <<-CODE
        def #{method}(name)
          (0..(#{count} - 1)).each do |i|
            it = #{single}(i)
            return it if it.name == name
          end
          nil
        end
      CODE
    end

    def name
      Lib.g_base_info_get_name @gobj
    end

    def info_type
      Lib.g_base_info_get_type @gobj
    end

    def namespace
      Lib.g_base_info_get_namespace @gobj
    end

    def safe_namespace
      namespace.gsub(/^(.)/) { $1.upcase }
    end

    def container
      ptr = Lib.g_base_info_get_container @gobj
      Lib.g_base_info_ref ptr
      IRepository.wrap_ibaseinfo_pointer ptr
    end

    def deprecated?
      Lib.g_base_info_is_deprecated @gobj
    end

    def self.wrap ptr
      return nil if ptr.null?
      return new ptr
    end

    def == other
      Lib.g_base_info_equal @gobj, other.to_ptr
    end
  end
end
