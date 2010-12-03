module GirFFI
  # Wraps a GITypeInfo struct.
  # Represents type information, direction, transfer etc.
  class ITypeInfo < IBaseInfo
    def pointer?
      Lib.g_type_info_is_pointer @gobj
    end
    def tag
      Lib.g_type_info_get_tag @gobj
    end
    def param_type(index)
      ITypeInfo.wrap(Lib.g_type_info_get_param_type @gobj, index)
    end
    def interface
      ptr = Lib.g_type_info_get_interface @gobj
      IRepository.wrap_ibaseinfo_pointer ptr
    end
    def array_length
      Lib.g_type_info_get_array_length @gobj
    end
    def array_fixed_size
      Lib.g_type_info_get_array_fixed_size @gobj
    end
    def zero_terminated?
      Lib.g_type_info_is_zero_terminated @gobj
    end
    def n_error_domains
      Lib.g_type_info_get_n_error_domains @gobj
    end
    def error_domain(index)
      IErrorDomainInfo.wrap(Lib.g_type_info_get_error_domain @gobj, index)
    end
    ##
    build_array_method :error_domains

    def name
      raise "Should not call this for gir 0.6.5 ..."
    end
  end
end

