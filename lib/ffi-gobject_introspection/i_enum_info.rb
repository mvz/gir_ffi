module GObjectIntrospection
  # Wraps a GIEnumInfo struct if it represents an enum.
  # If it represents a flag, an IFlagsInfo object is used instead.
  class IEnumInfo < IRegisteredTypeInfo
    def n_values
      Lib.g_enum_info_get_n_values @gobj
    end
    def value(index)
      IValueInfo.wrap(Lib.g_enum_info_get_value @gobj, index)
    end
    ##
    build_array_method :values

    def storage_type
      Lib.g_enum_info_get_storage_type @gobj
    end
  end
end

