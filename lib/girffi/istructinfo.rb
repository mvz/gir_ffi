module GirFFI
  # Wraps a GIStructInfo struct.
  # Represents a struct.
  class IStructInfo < IRegisteredTypeInfo
    def n_fields; Lib.g_struct_info_get_n_fields @gobj; end
    def field index; IFieldInfo.wrap(Lib.g_struct_info_get_field @gobj, index); end

    build_array_method :field

    def n_methods; Lib.g_struct_info_get_n_methods @gobj; end
    def method index; IFunctionInfo.wrap(Lib.g_struct_info_get_method @gobj, index); end

    build_array_method :method

    def find_method name; IFunctionInfo.wrap(Lib.g_struct_info_find_method @gobj, name); end
    def size; Lib.g_struct_info_get_size @gobj; end
    def alignment; Lib.g_struct_info_get_alignment @gobj; end
    def gtype_struct?; Lib.g_struct_info_is_gtype_struct @gobj; end
  end
end
