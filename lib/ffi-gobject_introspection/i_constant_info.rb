module GObjectIntrospection
  # Wraps a GIConstantInfo struct; represents an constant.
  class IConstantInfo < IBaseInfo
    def value
      val = Lib::GIArgument.new
      Lib.g_constant_info_get_value @gobj, val
      return val
    end

    def constant_type
      ITypeInfo.wrap(Lib.g_constant_info_get_type @gobj)
    end
  end
end
