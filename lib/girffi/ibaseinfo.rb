module GirFFI
  class IBaseInfo
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

    def initialize gobj=nil
      raise "#{self.class} creation not implemeted" if gobj.nil?
      raise "Null Pointer" if gobj.null?
      @gobj = gobj
    end
    def name; Lib.g_base_info_get_name @gobj; end
    def type; Lib.g_base_info_get_type @gobj; end
    def namespace; Lib.g_base_info_get_namespace @gobj; end
    def deprecated?; Lib.g_base_info_is_deprecated @gobj; end

    def self.wrap ptr
      return nil if ptr.null?
      return self.new ptr
    end

    def == other
      self.name == other.name and
      self.type == other.type and
      self.namespace == other.namespace
    end
  end
end
