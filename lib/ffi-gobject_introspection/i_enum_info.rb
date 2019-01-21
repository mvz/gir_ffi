# frozen_string_literal: true

module GObjectIntrospection
  # Wraps a GIEnumInfo struct if it represents an enum.
  # If it represents a flag, an IFlagsInfo object is used instead.
  class IEnumInfo < IRegisteredTypeInfo
    def n_values
      Lib.g_enum_info_get_n_values self
    end

    def value(index)
      IValueInfo.wrap Lib.g_enum_info_get_value(self, index)
    end
    ##
    build_array_method :values
    build_finder_method :find_value, :n_values, :value

    def get_n_methods
      Lib.g_enum_info_get_n_methods self
    end

    def get_method(index)
      IFunctionInfo.wrap Lib.g_enum_info_get_method(self, index)
    end

    ##
    build_array_method :get_methods
    build_finder_method :find_method, :get_n_methods, :get_method

    def storage_type
      Lib.g_enum_info_get_storage_type self
    end
  end
end
