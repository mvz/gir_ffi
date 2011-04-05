module GirFFI
  # Wraps a GIStructInfo struct.
  # Represents a struct.
  class IStructInfo < IRegisteredTypeInfo
    def n_fields
      Lib.g_struct_info_get_n_fields @gobj
    end
    def field(index)
      IFieldInfo.wrap(Lib.g_struct_info_get_field @gobj, index)
    end

    ##
    build_array_method :fields

    def get_n_methods
      Lib.g_struct_info_get_n_methods @gobj
    end
    def get_method(index)
      IFunctionInfo.wrap(Lib.g_struct_info_get_method @gobj, index)
    end

    ##
    build_array_method :get_methods

    def find_method(name)
      @methods_hash ||= get_methods.inject({}) {|h,m| h[m.name] = m; h}
      @methods_hash[name]
    end

    def size
      Lib.g_struct_info_get_size @gobj
    end
    def alignment
      Lib.g_struct_info_get_alignment @gobj
    end
    def gtype_struct?
      Lib.g_struct_info_is_gtype_struct @gobj
    end
  end
end
