module GirFFI
  # Wraps a GIFieldInfo struct.
  # Represents a field of an IStructInfo or an IUnionInfo.
  class IFieldInfo < IBaseInfo
    def flags
      Lib.g_field_info_get_flags @gobj
    end
    def size
      Lib.g_field_info_get_size @gobj
    end
    def offset
      Lib.g_field_info_get_offset @gobj
    end
    def type
      ITypeInfo.wrap(Lib.g_field_info_get_type @gobj)
    end
  end
end
