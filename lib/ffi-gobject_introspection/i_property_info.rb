module GObjectIntrospection
  # Wraps a GIPropertyInfo struct.
  # Represents a property of an IObjectInfo or an IInterfaceInfo.
  class IPropertyInfo < IBaseInfo
    def property_type
      ITypeInfo.wrap(Lib.g_property_info_get_type @gobj)
    end

    def flags
      Lib.g_property_info_get_flags @gobj
    end

    def readable?
      flags & 1 != 0
    end

    def writeable?
      flags & 2 != 0
    end

    def construct?
      flags & 4 != 0
    end

    def construct_only?
      flags & 8 != 0
    end
  end
end
