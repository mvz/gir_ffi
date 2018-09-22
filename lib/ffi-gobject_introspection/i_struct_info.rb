# frozen_string_literal: true

module GObjectIntrospection
  # Wraps a GIStructInfo struct.
  # Represents a struct.
  class IStructInfo < IRegisteredTypeInfo
    def n_fields
      Lib.g_struct_info_get_n_fields self
    end

    def field(index)
      IFieldInfo.wrap Lib.g_struct_info_get_field(self, index)
    end

    ##
    build_array_method :fields
    build_finder_method :find_field

    def get_n_methods
      Lib.g_struct_info_get_n_methods self
    end

    def get_method(index)
      IFunctionInfo.wrap Lib.g_struct_info_get_method(self, index)
    end

    ##
    build_array_method :get_methods
    # There is a function g_struct_info_find_method but it causes a core dump.
    build_finder_method :find_method, :get_n_methods, :get_method

    def size
      Lib.g_struct_info_get_size self
    end

    def alignment
      Lib.g_struct_info_get_alignment self
    end

    def gtype_struct?
      Lib.g_struct_info_is_gtype_struct self
    end
  end
end
