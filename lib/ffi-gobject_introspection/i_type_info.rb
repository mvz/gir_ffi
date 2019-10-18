# frozen_string_literal: true

module GObjectIntrospection
  # Wraps a GITypeInfo struct.
  # Represents type information, direction, transfer etc.
  class ITypeInfo < IBaseInfo
    def pointer?
      return @pointer_eh if defined? @pointer_eh

      @pointer_eh = Lib.g_type_info_is_pointer self
    end

    def tag
      @tag ||= Lib.g_type_info_get_tag self
    end

    def param_type(index)
      @param_type_cache ||= []
      @param_type_cache[index] ||=
        ITypeInfo.wrap Lib.g_type_info_get_param_type(self, index)
    end

    def interface
      @interface ||= begin
                       ptr = Lib.g_type_info_get_interface self
                       IRepository.wrap_ibaseinfo_pointer ptr
                     end
    end

    def array_length
      @array_length ||= Lib.g_type_info_get_array_length self
    end

    def array_fixed_size
      Lib.g_type_info_get_array_fixed_size self
    end

    def array_type
      Lib.g_type_info_get_array_type self
    end

    def zero_terminated?
      Lib.g_type_info_is_zero_terminated self
    end

    def name
      raise "Should not call this for ITypeInfo"
    end
  end
end
