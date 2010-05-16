module GirFFI
  class IValueInfo < IBaseInfo
    def value; Lib.g_value_info_get_value @gobj; end
  end
end

