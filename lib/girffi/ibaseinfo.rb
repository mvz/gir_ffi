module GirFFI
  # Wraps GIBaseInfo struct, the base \type for all info types.
  # Decendant types will be implemented as needed.
  class IBaseInfo
    # This is a helper method to construct a method returning an array, out
    # of the methods returning their number and the individual elements.
    #
    # For example, given the methods +n_foos+ and +foo+(+i+), this method
    # will create an additional method +foos+ returning all args.
    #
    # Provide the second parameter if the plural is not trivially
    # constructed by adding +s+ to the singular.
    # --
    # TODO: Use plural as the first argument, to help RDoc
    def self.build_array_method elementname, plural = nil
      plural ||= "#{elementname}s"
      self.class_eval <<-CODE
	def #{plural}
	  (0..(n_#{plural} - 1)).map do |i|
	    #{elementname} i
	  end
	end
      CODE
    end

    def initialize gobj
      @gobj = gobj
    end
    private_class_method :new

    def name; Lib.g_base_info_get_name @gobj; end
    def type; Lib.g_base_info_get_type @gobj; end
    def namespace; Lib.g_base_info_get_namespace @gobj; end
    def deprecated?; Lib.g_base_info_is_deprecated @gobj; end

    def self.wrap ptr
      return nil if ptr.null?
      return new ptr
    end

    def == other
      self.name == other.name and
      self.type == other.type and
      self.namespace == other.namespace
    end
  end
end
