# frozen_string_literal: true

module GObjectIntrospection
  # Wraps a GIUnionInfo struct.
  # Represents a union.
  class IUnionInfo < IRegisteredTypeInfo
    def n_fields
      Lib.g_union_info_get_n_fields self
    end

    def field(index)
      IFieldInfo.wrap Lib.g_union_info_get_field(self, index)
    end

    ##
    build_array_method :fields

    def get_n_methods
      Lib.g_union_info_get_n_methods self
    end

    def get_method(index)
      IFunctionInfo.wrap Lib.g_union_info_get_method(self, index)
    end

    ##
    build_array_method :get_methods

    def find_method(name)
      IFunctionInfo.wrap Lib.g_union_info_find_method(self, name.to_s)
    end

    def size
      Lib.g_union_info_get_size self
    end

    def alignment
      Lib.g_union_info_get_alignment self
    end
  end
end
