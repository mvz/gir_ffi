module GirFFI
  # Wraps a GIUnionInfo struct.
  # Represents a union.
  # Not implemented yet.
  class IUnionInfo < IRegisteredTypeInfo
    def n_fields; Lib.g_union_info_get_n_fields @gobj; end
    def field(index); IFieldInfo.wrap(Lib.g_union_info_get_field @gobj, index); end

    ##
    build_array_method :fields

    def n_methods; Lib.g_union_info_get_n_methods @gobj; end
    def method(index); IFunctionInfo.wrap(Lib.g_union_info_get_method @gobj, index); end

    ##
    build_array_method :methods

    def find_method(name); IFunctionInfo.wrap(Lib.g_union_info_find_method @gobj, name); end
    def size; Lib.g_union_info_get_size @gobj; end
    def alignment; Lib.g_union_info_get_alignment @gobj; end
  end
end
