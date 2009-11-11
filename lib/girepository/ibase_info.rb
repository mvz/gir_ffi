module GIRepository
  class IBaseInfo
    def self.build_array_method elementname, plural = nil
      plural ||= "#{elementname}s"
      define_method "#{plural}" do
	(0..((send "n_#{plural}") - 1)).map do |i|
	  send elementname, i
	end
      end
    end

    def initialize gobj=nil
      raise "#{self.class} creation not implemeted" if gobj.nil?
      @gobj = gobj
    end
    def name; Lib.g_base_info_get_name @gobj; end
    def type; Lib.g_base_info_get_type @gobj; end
    def namespace; Lib.g_base_info_get_namespace @gobj; end
    def deprecated?; Lib.g_base_info_is_deprecated @gobj; end
    def to_s
      s = "#{type} #{name}"
      s << ", DEPRECATED" if deprecated? 
      s
    end
  end
end
